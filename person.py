class Person:
    def __init__(self, name, surname, tckn, phone, address):
        self.name = name
        self.surName = surname
        self.tckn = tckn
        self.phone = phone
        self.address = address

    def showPerson(self):
        print("Name: {}\nSurname: {}\nTCKN: {}\nPhone: {}\nAddress: {}\n".format(self.name, self.surName, self.tckn, self.phone, self.address))



