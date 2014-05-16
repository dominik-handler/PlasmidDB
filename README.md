# Plasmid tracking database

Manages the collection of Plasmids in the BrenneckeLab at the Institute of Molecular Biotechnology (IMBA) in Vienna.

Built on top Rails 3.2 using Ruby 1.9.3. Runs backups of the DB once a day via [backup](https://github.com/meskyanichi/backup) and [sidekiq](https://github.com/mperham/sidekiq).

There are no tests available, thus it is unclear exactly how production ready it is. You have been warned..
