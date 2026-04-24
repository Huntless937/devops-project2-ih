resource_group_name = "rg-tfstate-Group7"
location            = "northeurope"

vnet_address_space = ["10.0.0.0/16"]

subnets = {
  appgw    = { address_prefix = "10.0.0.0/24" }
  frontend = { address_prefix = "10.0.1.0/24" }
  backend  = { address_prefix = "10.0.2.0/24" }
  data     = { address_prefix = "10.0.3.0/24" }
  ops      = { address_prefix = "10.0.4.0/24" }
}

admin_username = "azureuser-group7"
ssh_public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCh6PaIhhcXbPyp7DecjPh7Ss2X/EAqodk9X63FwBBtlKU+Bbwt9JxgEaSX7bhi6yPaZUJKdBuoET28D3PvzPwsAjo8aqErkXSTDIV3xp9cTJVD5QqbvyhBtCdz+7lnuwwzx0Sme12ytGAQAn9I89w2FTMVFJayhepK7dOrMT+31gh4AGK3Bn0d/aO4lMUalsYuKdoESozeAPQ03KDNrWoZ7bKZHkcf90jHoHjEpeGBiHOw4ouJnWogl5+RQ6/vP3YCpBKkVaP/AOYeVqW+lBLkOFUvcw1GJrUx0k4bfukZEgBhAf2D0WThLrrmnJ/pplJisKtN1OI2YvOzDFzmGfI6I5DdATxmYvvTMCzOvOYA9kREdus3Mb3hB1GyWPY6exZpfeA1CjeQjgJdHqeq12lBUSPBwOTEsfuZIP9ksH4NVuPaaJ8YE1/5vK283Z4up+r9wDgKvJ9d70SCTy0BncB8cldbRtX/EMTZbo7/swdbQdxUlqEstSFyoOLo053tCdBo+b7Zxoy8E6xanFrDlYqnthE+kjS4X8KfoU5+TYpsAf11gfIBK5iu7cT2Vc6kMho6kM4YDnlMuF5TWiB9KBKig96iuCU1Pi1GbcuRTo8UM3KJ5ydVFSYBWmIHQ68ZHaJAddESaUbERv5OChNVabqOoSUUQOf/werqqVm8Udytvw=="
vm_size = "Standard_D2ads_v7"

sql_server_name    = "sql-burgerbuilder-group7"
sql_database_name  = "burgerbuilderdbgroup7"
sql_admin_username = "sqladmingroup7"
sql_admin_password = "Group7-Group7"