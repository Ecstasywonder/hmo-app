const validateReview = (req, res, next) => {
  const { rating, comment } = req.body;

  const errors = [];

  if (!rating) {
    errors.push('Rating is required');
  } else if (!Number.isInteger(rating) || rating < 1 || rating > 5) {
    errors.push('Rating must be an integer between 1 and 5');
  }

  if (comment && typeof comment !== 'string') {
    errors.push('Comment must be a string');
  }

  if (comment && comment.length > 1000) {
    errors.push('Comment must not exceed 1000 characters');
  }

  if (errors.length > 0) {
    return res.status(400).json({
      success: false,
      errors
    });
  }

  next();
};

module.exports = {
  validateReview
}; 