import psycopg2
import address
import area as a
import city as c
import district as d
import address as ad
import person
import courier
import warehouseStaff
import customer
import warehouse
import pack
import role
import paymentType
from prettytable import PrettyTable

host = "localhost"
databaseName = "postOffice"
port = 5432
password = "123456"
user = "postgres"

try:
    conn = psycopg2.connect(
        host=host,
        dbname=databaseName,
        user=user,
        password=password,
        port=port
    )
    cur = conn.cursor()
except Exception as error:
    print("Hata:", error)

while True:
    print("Menü:")
    print("1. Adres işlemleri")
    print("2. Kişi işlemleri")
    print("3. Depo işlemleri")
    print("4. Kargo işlemleri")
    print("5. Çıkış")

    choice = input("Lütfen bir seçenek numarası girin (1-5): ")

    if choice == "1":
        while True:
            print("\nAdres İşlemleri Menüsü:")
            print("1. Şehir Ekle")
            print("2. İlçe Ekle")
            print("3. Mahalle Ekle")
            print("4. Adres Ekle")
            print("5. Çıkış")

            secim = input("Lütfen bir seçenek numarası girin (1-6): ")

            if secim == "1":
                name = input("Şehir adı: ")
                c.City(name).QueryCityTable(c.City(name), cur, conn)
            elif secim == "2":
                name = input("İlçe adı: ")
                city = input("İl adı: ")
                d.District(name, city).QueryDistrictTable(d.District(name, city), cur, conn)
            elif secim == "3":
                name = input("Mahalle adı: ")
                district = input("İlçe adı: ")
                city = input("İl adı: ")
                a.Area(name, district, city).QueryAreaTable(a.Area(name, district, city), cur, conn)
            elif secim == "4":
                city = input("İl adı: ")
                district = input("İlçe adı: ")
                area = input("Mahalle adı: ")
                detail = input("Adres detayı: ")
                tckn = input("TCKN: ")
                role.Role.ListRole(cur)
                role = input("Kişi rolü: ")
                id = person.Person.GetId(tckn, cur, role)
                ad.Address(city, district, area, detail, id).QueryAddressTable(ad.Address(city, district, area, detail, id), cur, conn)

            elif secim == "5":
                print("Programdan çıkılıyor...")
                break
            else:
                print("Geçersiz bir seçenek girdiniz. Lütfen 1-5 arasında bir seçenek belirtin.")

    elif choice == "2":
        print("Seçenek 2 seçildi.")

    elif choice == "3":
        while True:
            print("\nDepo işlemleri menüsü:")
            tckn = input("Depo görevlisi TCKN: ")
            idStaff = warehouseStaff.WarehouseStaff.IsWarehouseStaff(tckn, cur)
            if id == None:
                break
            while True:
                while True:
                    print("\nDepo İşlemleri Menüsü")
                    print("1. Kargo Ekle")
                    print("2. Kargo Sil")
                    print("3. Kurye Ata")
                    print("4. Çıkış")
                    secim = input("Lütfen bir seçenek numarası girin (1-4): ")

                    if secim == '1':
                        print("Müşteri bilgisini giriniz:")
                        tckn = input("TCKN: ")
                        idCustomer = customer.Customer.IsCustomer(tckn, cur)
                        if idCustomer == None:
                            name = input("İsim: ")
                            surname = input("Soyisim: ")
                            phone = input("Telefon: ")
                            priority = input("Öncelik: ")
                            address = 0;
                            idCustomer = customer.Customer(name, surname, tckn, phone, address, priority).QueryCustomerTable(customer.Customer(name, surname, tckn, phone, address, priority), cur, conn)
                            print("Müşteri kaydı başarıyla oluşturuldu.")
                            city = input("İl adı: ")
                            district = input("İlçe adı: ")
                            area = input("Mahalle adı: ")
                            detail = input("Adres detayı: ")
                            address = ad.Address(city, district, area, detail, idCustomer).QueryAddressTable(ad.Address(city, district, area, detail, idCustomer), cur, conn)
                            print("Adres kaydı başarıyla oluşturuldu.")
                        else:
                            print("Müşteri kaydı bulundu.")
                            city = input("İl adı: ")
                            district = input("İlçe adı: ")
                            area = input("Mahalle adı: ")
                            detail = input("Adres detayı: ")
                            address = ad.Address(city, district, area, detail, idCustomer).QueryAddressTable(ad.Address(city, district, area, detail, idCustomer), cur, conn)

                        print("Ödeme tipini seçiniz:")
                        paymentType.PaymentType.ListPaymentType(cur)
                        paymentType = input("Ödeme tipi: ")
                        print("Kargo bilgisini giriniz:")
                        mass = input("Kargo ağırlığı: ")
                        pack = pack.Pack(address, idCustomer, idStaff, 0, mass, 0, paymentType, 4, 0)
                        pack.AddPackTable(cur, conn)
                        query = f"SELECT last_value FROM pack_id_seq";
                        cur.execute(query)
                        rows = cur.fetchall()
                        id = rows[0][0]
                        query = f"SELECT * FROM update_pack_cost({id}, {mass});"
                        cur.execute(query)
                        conn.commit()
                        print("Kargo kaydı başarıyla oluşturuldu.")
                    elif secim == '2':
                        print("Müşteri bilgisini giriniz:")
                        tckn = input("TCKN: ")
                        pack.Pack.ListPacksCustomer(tckn, cur)
                        idPack = input("Kargo ID: ")
                        pack.Pack.DeletePack(idPack, cur, conn)
                        print("Kargo kaydı başarıyla silindi.")
                    elif secim == '3':
                        query = f"SELECT pack.id, customer.priority FROM pack JOIN CUSTOMER ON customer.id = pack.customer WHERE courier = 0;"
                        cur.execute(query)
                        rows = cur.fetchall()
                        if len(rows) == 0:
                            print("\nKurye atanacak kargo bulunmamaktadır.")
                        else:
                            prettytable = PrettyTable()
                            prettytable.field_names = ["ID", "Öncelik"]
                            for row in rows:
                                prettytable.add_row(row)
                            print(prettytable)
                            idPack = input("Kargo ID: ")
                            tckn = input("Kurye TCKN: ")
                            idCourier = courier.Courier.IsCourier(tckn, cur)
                            query = f"UPDATE pack SET courier = {idCourier}, status = 3 WHERE id = {idPack};"
                            cur.execute(query)
                            conn.commit()
                    elif secim == '4':
                        print("Programdan çıkılıyor...")
                        break
                    else:
                        print("Geçersiz bir seçenek girdiniz.Lütfen 1-4 arasında bir seçenek belirtin.")

    elif choice == "4":
        while True:
            print("\nPaket işlemleri menüsü:")
            tckn = input("Kurye TCKN: ")
            id = courier.Courier.IsCourier(tckn, cur)
            if id == None:
                break
            while True:
                print(pack.Pack.ListPacksCourier(id, cur))
                print("\nPaket İşlemleri Menüsü:")
                print("1. Paketi Teslim Et")
                print("2. Paketi İptal Et")
                print("3. Çıkış")
                idPack = int(input("\nKargo ID giriniz"))
                secim = input("\nLütfen bir seçenek numarası girin (1-3): ")
                if secim == "1":
                    score = input("Kurye puanı(1-10): ")
                    query = f"UPDATE PACK SET score = {score} WHERE id = {idPack};"
                    cur.execute(query)
                    conn.commit()
                    query = f"UPDATE courier SET \"deliveredPack\" = \"deliveredPack\" + 1 WHERE id = {id};"
                    cur.execute(query)
                    conn.commit()
                    pack.Pack.UpdatePackStatus(idPack, cur, conn, 1)
                    query = f"SELECT * FROM create_receipt({idPack});"
                    print("Paket teslim edildi.")
                elif secim == "2":
                    pack.Pack.UpdatePackStatus(idPack, cur, conn, 2)
                    print("İptal edilen paketi depoya döndürmek ister misiniz?.")
                    secim = input("Lütfen bir seçenek numarası girin (1-2): ")
                    if secim == "1":
                        query = f"SELECT * FROM update_pack_status_courier({idPack});"
                        cur.execute(query)
                        conn.commit()
                        print("Paket depoya döndürüldü.")
                        break
                elif secim == "3":
                    print("Programdan çıkılıyor...")
                    break
                else:
                    print("Geçersiz bir seçenek girdiniz. Lütfen 1-3 arasında bir seçenek belirtin.")

    elif choice == "5":
        print("Çıkış yapılıyor...")
        break

    else:
        print("Geçersiz bir seçenek girdiniz. Lütfen 1-5 arasında bir seçenek belirtin.")





conn.close()
cur.close()