import secrets
import string


def generate_password(length=20):
    if length < 16:
        raise ValueError("Password length should be at least 16 characters")

    alphabet = string.ascii_letters + string.digits + "-"
    return "".join(secrets.choice(alphabet) for _ in range(length))


password = generate_password()
print(password)
