const Joi = require('joi');
const { ValidationError } = require('../../utils/errors');

const paymentValidation = {
  initialize: (req, res, next) => {
    const schema = Joi.object({
      planId: Joi.string().uuid().required(),
      paymentMethod: Joi.string().valid('card', 'bank_transfer', 'debit', 'ussd').required()
    });

    const { error } = schema.validate(req.body);
    if (error) throw new ValidationError(error.details[0].message);
    next();
  },

  verify: (req, res, next) => {
    const schema = Joi.object({
      transactionRef: Joi.string().required()
    });

    const { error } = schema.validate(req.params);
    if (error) throw new ValidationError(error.details[0].message);
    next();
  },

  bankAccount: (req, res, next) => {
    const schema = Joi.object({
      accountNumber: Joi.string().length(10).required(),
      bankCode: Joi.string().required(),
      bankName: Joi.string().required()
    });

    const { error } = schema.validate(req.body);
    if (error) throw new ValidationError(error.details[0].message);
    next();
  },

  receipt: (req, res, next) => {
    const schema = Joi.object({
      paymentId: Joi.string().uuid().required()
    });

    const { error } = schema.validate(req.params);
    if (error) throw new ValidationError(error.details[0].message);
    next();
  }
};

module.exports = paymentValidation; 