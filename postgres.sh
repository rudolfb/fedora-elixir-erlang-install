sudo dnf install nano -y
sudo dnf upgrade -y

# https://fedoraproject.org/wiki/PostgreSQL

sudo dnf install postgresql-server postgresql-contrib -y
sudo systemctl enable postgresql
sudo postgresql-setup --initdb --unit postgresql
sudo systemctl start postgresql

sudo dnf install pgadmin3 -y

sudo su - postgres
psql -U postgres template1 -c "alter user postgres with password 'postgres';"
exit
