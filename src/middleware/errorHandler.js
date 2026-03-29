// Global error handler — attach at the very bottom of server.js
const errorHandler = (err, req, res, next) => {
  console.error("Unhandled error:", err.message);
  res.status(500).json({ success: false, error: err.message });
};

module.exports = errorHandler;
