Modular Linux server fleet monitoring, alerting, and automated maintenance system written in Bash.

## Structure
- `monitor.sh` - Entry point (parsing, dispatch, locking, interactive menu)
- `config/` - Configuration for thresholds and host fleet targets
- `lib/` - Core execution modules (common helpers, system checks, reports, maintenance)
