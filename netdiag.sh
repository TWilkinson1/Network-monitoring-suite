#!/bin/bash

# Network Diagnostic Suite
# A comprehensive tool for network troubleshooting
# Author: Thomas Wilkinson
# Version: 1.0

# Set script directory

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

#source common functions and modules

source "$SCRIPT_DIR/modules/common.sh"
source "$SCRIPT_DIR/modules/dns_tools.sh"
source "$SCRIPT_DIR/modules/port_scanner.sh"
source "$SCRIPT_DIR/modules/route_tracer.sh"
source "$SCRIPT_DIR/modules/perf_tester.sh"

#config
CONFIG_FILE="$SCRIPT_DIR/config/netdiag.conf"
if [ ! -f "$CONFIG_FILE" ]; then
    echo "Configuration file not found: $CONFIG_FILE"
    exit 1
fi

#Display banner
display_banner() {
    echo "----------------------------------------"
    echo "       Network Diagnostic Suite         "
    echo "----------------------------------------"
    echo "Version: 1.0"
    echo "Author: Your Name"
    echo "----------------------------------------"
}

#Display usage

display_usage() {
    echo "Usage: $0 [options] [target]"
    echo "Options:"
    echo "  -h, --help        Show this help message"
    echo "  -d, --dns         Run DNS diagnostics"
    echo "  -p, --port        Run port scanning"
    echo "  -t, --traceroute  Run traceroute"
    echo "  -f, --perf        Run performance tests"
    echo "  -c, --config      Specify configuration file (default: $CONFIG_FILE)"
    echo "Example:"
    echo " $0 --dns example.com Run DNS diagnostics on example.com"
    echo " $0 --all 8.8.8.8 Run diagnostics on 8.8.8.8"
}

#process cmd line arguments
process_args(){
    if [[ $# -eq 0 ]]; then
        display_usage
        exit 0
    fi

    while [[ $# -gt 0 ]]; do
        case "$1" in
            -h|--help)
             display_usage
             exit 0
             ;;
            -d|--dns)
                if [[ -z "$2" || "$2" == -* ]]; then
                    echo "Error: Missing target for DNS diagnostics"
                    exit 1
                fi
                TARGET="$2"
                shift 2
                run_dns_diagnostics "$TARGET"
                ;;
            -p|--port)
                if [[ -z "$2" || "$2" == -* ]]; then
                    log_error "Error: Missing target for port scanning"
                    exit 1
                fi
                HOST="$2"
                PORTS="$3"
                if [[ -z "$PORTS" || "$PORTS" == -* ]]; then
                    PORTS="common"
                    shift 3
                else
                    shift 2
                fi
                run_port_scan "$HOST" "$PORTS"
                ;;
            -r|--route)
                if [[ -z "$2" || "$2" == -*]]; then
                    log_error "Error: Missing target for traceroute"
                    exit 1
                fi
                TARGET="$2"
                run_route_trace "$TARGET"
                shift 2
                ;;
            -t | --test)
                if [[ -z "$2" || "$2" == -* ]]; then
                    log_error "Error: Missing target for performance test"
                    exit 1
                fi
                TARGET="$2"
                run_performance_test "$TARGET"
                shift 2
                ;;
            -v | --verbose)
                VERBOSE=true
                export VERBOSE
                shift
                ;;
            -o | --output)
                if [[ -z "$2" || "$2" == -* ]]; then
                    log_error "Error: Missing output file"
                    exit 1
                fi
                OUTPUT_FILE="$2"
                shift 2
                ;;
            *)
                log_error "Error: Unknown option $1"
                display_usage
                exit 1
                ;;
        esac
    done
}

#run_diagnostics
run_all_diagnostics() {
    local target="$1"
    
    log_info "Running all diagnostics on $target"

    #Ip or domain check
    if [[ "$target" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$]]; then
        #if ip
        host_ip="$target"
        host_name=$(dig +short -x "$target" 2>/dev/null || echo "Unknown")
    else
        #if domain
        host_name="$target"
        host_ip=$(dig +short "$target" 2>/dev/null || echo "Unknown")
    fi

}