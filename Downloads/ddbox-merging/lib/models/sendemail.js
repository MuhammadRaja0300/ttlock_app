
const sendGrid = require('@sendgrid/mail');
sendGrid.setApiKey('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');

function sendEmail(toEmail, password) {
  const msg = {
    to: toEmail,
    from: 'muneebumughal84@icloud.com',
    subject: 'Your Password',
    text: `Your password is: ${password}`,
  };

  sendGrid.send(msg)
    .then(() => console.log('Email sent successfully'))
    .catch(error => console.error(`Error sending email: ${error}`));
}

module.exports = sendEmail;
