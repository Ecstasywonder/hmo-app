const Joi = require('joi');

const validateRegistration = (data) => {
  const schema = Joi.object({
    firstName: Joi.string().required().trim(),
    lastName: Joi.string().required().trim(),
    email: Joi.string().email().required().trim(),
    password: Joi.string().min(8).required(),
    phoneNumber: Joi.string().required().trim()
  });

  return schema.validate(data);
};

const validateLogin = (data) => {
  const schema = Joi.object({
    email: Joi.string().email().required().trim(),
    password: Joi.string().required()
  });

  return schema.validate(data);
};

const validateForgotPassword = (data) => {
  const schema = Joi.object({
    email: Joi.string().email().required().trim()
  });
  return schema.validate(data);
};

const validateResetPassword = (data) => {
  const schema = Joi.object({
    token: Joi.string().required(),
    newPassword: Joi.string().min(8).required()
  });
  return schema.validate(data);
};

module.exports = {
  validateRegistration,
  validateLogin,
  validateForgotPassword,
  validateResetPassword
}; 