import logging
import smtplib
import traceback
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText
from typing import List, Dict, Any

from ..config import settings
from ..core.exceptions import EmailException

logger = logging.getLogger(__name__)


async def send_email(
    recipients: List[str],
    subject: str,
    body: str,
    html_body: str = None,
) -> bool:
    """
    Send an email to the specified recipients.
    
    Args:
        recipients: List of recipient email addresses
        subject: Email subject
        body: Email body (plain text)
        html_body: Email body (HTML) - optional
        
    Returns:
        bool: Whether the email was sent successfully
    """
    try:
        logger.debug(f"Attempting to send email to: {recipients}")
        logger.debug(f"Using SMTP server: {settings.SMTP_SERVER}:{settings.SMTP_PORT}")
        logger.debug(f"Using sender: {settings.EMAIL_SENDER}")
        
        msg = MIMEMultipart('alternative')
        msg['Subject'] = subject
        msg['From'] = settings.EMAIL_SENDER
        msg['To'] = ", ".join(recipients)
        
        # Attach plain text version
        msg.attach(MIMEText(body, 'plain'))
        
        # Attach HTML version if provided
        if html_body:
            msg.attach(MIMEText(html_body, 'html'))
        
        # Connect to SMTP server and send email
        logger.debug("Connecting to SMTP server...")
        with smtplib.SMTP(settings.SMTP_SERVER, settings.SMTP_PORT) as server:
            logger.debug("Starting TLS...")
            server.starttls()
            logger.debug("Logging in...")
            server.login(settings.EMAIL_SENDER, settings.EMAIL_PASSWORD)
            logger.debug("Sending message...")
            server.send_message(msg)
            
        logger.info(f"Email sent to {len(recipients)} recipients")
        return True
    
    except Exception as e:
        logger.error(f"Error sending email: {e}")
        logger.error(traceback.format_exc())
        # Log the SMTP settings (without the password)
        logger.error(f"SMTP Server: {settings.SMTP_SERVER}")
        logger.error(f"SMTP Port: {settings.SMTP_PORT}")
        logger.error(f"Email Sender: {settings.EMAIL_SENDER}")
        # Don't raise exception to prevent 500 errors
        # Just log the error and return False
        return False


async def send_verification_email(email: str, verification_code: str) -> bool:
    """
    Send a verification email with the verification code.
    
    Args:
        email: Recipient email address
        verification_code: Verification code to include in the email
        
    Returns:
        bool: Whether the email was sent successfully
    """
    subject = f"{settings.APP_NAME} - Verify Your Email"
    
    text_body = f"""
    Welcome to {settings.APP_NAME}!
    
    Your verification code is: {verification_code}
    
    Please enter this code in the app to verify your email address.
    
    Thank you,
    The {settings.APP_NAME} Team
    """
    
    html_body = f"""
    <html>
        <body>
            <h2>Welcome to {settings.APP_NAME}!</h2>
            <p>Your verification code is: <strong>{verification_code}</strong></p>
            <p>Please enter this code in the app to verify your email address.</p>
            <p>Thank you,<br>The {settings.APP_NAME} Team</p>
        </body>
    </html>
    """
    
    return await send_email([email], subject, text_body, html_body)


async def send_password_reset_email(email: str, verification_code: str) -> bool:
    """
    Send a password reset email with the verification code.
    
    Args:
        email: Recipient email address
        verification_code: Verification code to include in the email
        
    Returns:
        bool: Whether the email was sent successfully
    """
    subject = f"{settings.APP_NAME} - Password Reset"
    
    text_body = f"""
    You requested a password reset for your {settings.APP_NAME} account.
    
    Your verification code is: {verification_code}
    
    Please enter this code in the app to reset your password.
    
    If you did not request this, please ignore this email.
    
    Thank you,
    The {settings.APP_NAME} Team
    """
    
    html_body = f"""
    <html>
        <body>
            <h2>Password Reset for {settings.APP_NAME}</h2>
            <p>You requested a password reset for your account.</p>
            <p>Your verification code is: <strong>{verification_code}</strong></p>
            <p>Please enter this code in the app to reset your password.</p>
            <p>If you did not request this, please ignore this email.</p>
            <p>Thank you,<br>The {settings.APP_NAME} Team</p>
        </body>
    </html>
    """
    
    return await send_email([email], subject, text_body, html_body)
