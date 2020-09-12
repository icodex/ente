import { template } from "./vernacularStrings";

/**
 * Global English constants.
 */
const englishConstants = {
    COMPANY_NAME: 'ente',
    LOGIN: 'Login',
    EMAIL: 'Email Address',
    ENTER_EMAIL: 'Enter email',
    EMAIL_DISCLAIMER: `We'll never share your email with anyone else.`,
    SUBMIT: 'Submit',
    EMAIL_ERROR: 'Enter a valid email address',
    REQUIRED: 'Required',
    VERIFY_EMAIL: 'Verify Email',
    EMAIL_SENT: ({ email }) => (<p>We have sent a mail to <b>{email}</b>.</p>),
    CHECK_INBOX: 'Please check your inbox (and spam) to complete verification.',
    ENTER_OTT: 'Enter verification code here',
    RESEND_MAIL: 'Did not get email?',
    VERIFY: 'Verify',
    UNKNOWN_ERROR: 'Oops! Something went wrong. Please try again.',
    INVALID_CODE: 'Invalid verification code',
    SENDING: 'Sending...',
    SENT: 'Sent! Check again.',
    ENTER_PASSPHRASE: 'Please enter your passphrase.',
    RETURN_PASSPHRASE_HINT: 'That thing you promised to never forget.',
    SET_PASSPHRASE: 'Set Passphrase',
    INCORRECT_PASSPHRASE: 'Incorrect Passphrase',
    ENTER_ENC_PASSPHRASE: 'Please enter a passphrase that we can use to encrypt your data.',
    PASSPHRASE_DISCLAIMER: () => (
        <p>
            We don't store your passphrase, so if you forget,
            <strong> we will not be able to help you</strong> recover your data.
        </p>
    ),
    PASSPHRASE_HINT: 'Something you will never forget',
    PASSPHRASE_CONFIRM: 'Please repeat it once more',
    PASSPHRASE_MATCH_ERROR: `Passphrase didn't match`,
};

export default englishConstants;
