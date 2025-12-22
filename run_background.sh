#!/bin/bash

# Background service script
# Usage: ./run_background.sh [start|stop|restart|status|logs] [api]

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VENV_DIR="$SCRIPT_DIR/venv"
PID_FILE="$SCRIPT_DIR/douk_downloader.pid"
LOG_DIR="$SCRIPT_DIR/logs"
LOG_FILE="$LOG_DIR/douk_downloader.log"
ERROR_LOG="$LOG_DIR/douk_downloader_error.log"

# Create log directory
mkdir -p "$LOG_DIR"

# Check virtual environment
if [ ! -d "$VENV_DIR" ]; then
    echo "[ERROR] Virtual environment does not exist!"
    echo "Please run: ./setup_and_run.sh"
    exit 1
fi

# Get PID
get_pid() {
    if [ -f "$PID_FILE" ]; then
        cat "$PID_FILE"
    fi
}

# Check if process is running
is_running() {
    local pid=$(get_pid)
    if [ -n "$pid" ] && kill -0 "$pid" 2>/dev/null; then
        return 0
    else
        return 1
    fi
}

# Start service
start_service() {
    local mode=${1:-api}
    
    if is_running; then
        echo "[WARNING] Service is already running (PID: $(get_pid))"
        return 1
    fi
    
    echo "[INFO] Starting service (mode: $mode)..."
    
    # Activate virtual environment and run in background
    cd "$SCRIPT_DIR"
    source "$VENV_DIR/bin/activate"
    
    # Run in background using nohup
    nohup python main.py "$mode" >> "$LOG_FILE" 2>> "$ERROR_LOG" &
    local pid=$!
    echo $pid > "$PID_FILE"
    
    # Wait a moment to confirm startup
    sleep 2
    
    if is_running; then
        echo "[SUCCESS] Service started successfully!"
        echo "   PID: $pid"
        echo "   Log: $LOG_FILE"
        echo "   Error log: $ERROR_LOG"
        if [ "$mode" == "api" ]; then
            echo "   API URL: http://0.0.0.0:5555"
            echo "   API Docs: http://0.0.0.0:5555/docs"
        fi
    else
        echo "[ERROR] Service failed to start, please check error log: $ERROR_LOG"
        rm -f "$PID_FILE"
        return 1
    fi
}

# Stop service
stop_service() {
    if ! is_running; then
        echo "[WARNING] Service is not running"
        rm -f "$PID_FILE"
        return 1
    fi
    
    local pid=$(get_pid)
    echo "[INFO] Stopping service (PID: $pid)..."
    
    kill "$pid" 2>/dev/null
    
    # Wait for process to terminate
    local count=0
    while kill -0 "$pid" 2>/dev/null && [ $count -lt 10 ]; do
        sleep 1
        count=$((count + 1))
    done
    
    # If still running, force kill
    if kill -0 "$pid" 2>/dev/null; then
        echo "[WARNING] Force stopping service..."
        kill -9 "$pid" 2>/dev/null
    fi
    
    rm -f "$PID_FILE"
    echo "[SUCCESS] Service stopped"
}

# Restart service
restart_service() {
    local mode=${1:-api}
    stop_service
    sleep 1
    start_service "$mode"
}

# Show status
show_status() {
    if is_running; then
        local pid=$(get_pid)
        echo "[SUCCESS] Service is running"
        echo "   PID: $pid"
        echo "   Start time: $(ps -p $pid -o lstart= 2>/dev/null || echo 'Unknown')"
        echo "   Memory usage: $(ps -p $pid -o rss= 2>/dev/null | awk '{printf "%.2f MB", $1/1024}' || echo 'Unknown')"
        echo "   Log file: $LOG_FILE"
        echo "   Error log: $ERROR_LOG"
    else
        echo "[ERROR] Service is not running"
        rm -f "$PID_FILE"
    fi
}

# Show logs
show_logs() {
    local lines=${1:-50}
    if [ -f "$LOG_FILE" ]; then
        echo "=== Last $lines lines of log ==="
        tail -n "$lines" "$LOG_FILE"
    else
        echo "Log file does not exist: $LOG_FILE"
    fi
}

# Show error logs
show_error_logs() {
    local lines=${1:-50}
    if [ -f "$ERROR_LOG" ]; then
        echo "=== Last $lines lines of error log ==="
        tail -n "$lines" "$ERROR_LOG"
    else
        echo "Error log file does not exist: $ERROR_LOG"
    fi
}

# Follow logs in real-time
follow_logs() {
    if [ -f "$LOG_FILE" ]; then
        echo "Following log in real-time (Press Ctrl+C to exit)..."
        tail -f "$LOG_FILE"
    else
        echo "Log file does not exist: $LOG_FILE"
    fi
}

# Main logic
case "${1:-start}" in
    start)
        start_service "${2:-api}"
        ;;
    stop)
        stop_service
        ;;
    restart)
        restart_service "${2:-api}"
        ;;
    status)
        show_status
        ;;
    logs)
        show_logs "${2:-50}"
        ;;
    error-logs|error)
        show_error_logs "${2:-50}"
        ;;
    follow|tail)
        follow_logs
        ;;
    *)
        echo "Usage: $0 {start|stop|restart|status|logs|error-logs|follow} [api]"
        echo ""
        echo "Commands:"
        echo "  start [api]      - Start service (default: API mode)"
        echo "  stop             - Stop service"
        echo "  restart [api]   - Restart service"
        echo "  status           - Show service status"
        echo "  logs [lines]     - Show logs (default: 50 lines)"
        echo "  error-logs [lines] - Show error logs (default: 50 lines)"
        echo "  follow           - Follow logs in real-time"
        echo ""
        echo "Examples:"
        echo "  $0 start api     # Start API mode in background"
        echo "  $0 status        # Show status"
        echo "  $0 logs 100      # Show last 100 lines of log"
        echo "  $0 follow        # Follow log in real-time"
        exit 1
        ;;
esac

