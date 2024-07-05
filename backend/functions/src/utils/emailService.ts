import dotenv from 'dotenv';
import { Resend } from 'resend';

dotenv.config();
const resendKey = process.env.RESEND_KEY || '';

if (!resendKey) {
  throw new Error('RESEND_KEY environment variable is not set');
}

const resend = new Resend(resendKey);

export const sendVerificationCode = async (email: string, code: string) => {
  const mailOptions = {
    from: 'auth@clarifyapp.io',
    to: email,
    subject: 'Your Verification Code',
    text: `Your verification code is: ${code}`,
  };

  try {
    await resend.emails.send(mailOptions);
    console.log('Verification code sent successfully');
  } catch (error) {
    console.error('Error sending verification code:', error);
    throw new Error(`Failed to send verification code to ${email}`);
  }
};
