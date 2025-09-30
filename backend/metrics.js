const client = require('prom-client');

// Create a Registry to register metrics
const register = new client.Registry();

// Add default Node.js metrics
client.collectDefaultMetrics({ register });

// Custom metrics for expense tracker
const httpRequestDuration = new client.Histogram({
  name: 'http_request_duration_seconds',
  help: 'Duration of HTTP requests in seconds',
  labelNames: ['method', 'route', 'status_code'],
  buckets: [0.1, 0.3, 0.5, 0.7, 1, 3, 5, 7, 10]
});

const httpRequestsTotal = new client.Counter({
  name: 'http_requests_total',
  help: 'Total number of HTTP requests',
  labelNames: ['method', 'route', 'status_code']
});

const activeUsers = new client.Gauge({
  name: 'expense_tracker_active_users',
  help: 'Number of currently active users'
});

const totalExpenses = new client.Gauge({
  name: 'expense_tracker_total_expenses',
  help: 'Total expenses amount'
});

const totalIncome = new client.Gauge({
  name: 'expense_tracker_total_income',
  help: 'Total income amount'
});

// Register metrics
register.registerMetric(httpRequestDuration);
register.registerMetric(httpRequestsTotal);
register.registerMetric(activeUsers);
register.registerMetric(totalExpenses);
register.registerMetric(totalIncome);

module.exports = {
  register,
  httpRequestDuration,
  httpRequestsTotal,
  activeUsers,
  totalExpenses,
  totalIncome
};
