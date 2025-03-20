# This script generates a bcrypt password
# Command : 'python3 pass-gen.py'
# Provide the initial password, validate to get the encrypted password

import getpass
import bcrypt

password = getpass.getpass("password: ")
hashed_password = bcrypt.hashpw(password.encode("utf-8"), bcrypt.gensalt())
print(hashed_password.decode())
