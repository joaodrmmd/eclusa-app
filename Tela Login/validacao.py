def validar(email, senha, usuarios):
	email_limpo = email.strip().lower()

	for usuario in usuarios:
		if usuario["email"] == email_limpo and usuario["senha"] == senha:
			return usuario

	return None