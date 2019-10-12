hook.Add("PlutoDatabaseInitialize", "pluto_db_init", function(db)
	pluto.db.transact {
		{
			[[
				CREATE TABLE IF NOT EXISTS pluto_tabs (
					idx int UNSIGNED NOT NULL AUTO_INCREMENT,
					owner BIGINT UNSIGNED NOT NULL,
					color INT UNSIGNED NOT NULL DEFAULT 0,
					tab_type varchar(16) NOT NULL DEFAULT "normal",
					name VARCHAR(16) NOT NULL,
					PRIMARY KEY(idx),
					INDEX USING HASH(owner)
				)
			]]
		},
		{
			[[
				CREATE TABLE IF NOT EXISTS pluto_items (
					idx INT UNSIGNED NOT NULL AUTO_INCREMENT,
					tier VARCHAR(16) NOT NULL,
					class VARCHAR(32) NOT NULL,

					tab_id INT UNSIGNED NOT NULL,
					tab_idx TINYINT UNSIGNED NOT NULL,

					FOREIGN KEY(tab_id) REFERENCES pluto_tabs(idx) ON DELETE CASCADE,
					PRIMARY KEY(tab_id, tab_idx),
					INDEX USING HASH(tab_id),

					INDEX USING HASH(idx)
				)
			]]
		},
		{
			[[
				CREATE TABLE IF NOT EXISTS pluto_mods (
					idx INT UNSIGNED NOT NULL AUTO_INCREMENT,
					gun_index INT UNSIGNED NOT NULL,
					modname VARCHAR(16) NOT NULL,
					tier TINYINT UNSIGNED NOT NULL,
					roll1 FLOAT,
					roll2 FLOAT,
					roll3 FLOAT,

					deleted BOOLEAN NOT NULL DEFAULT FALSE,
					PRIMARY KEY(idx),
					UNIQUE(gun_index, modname),
					INDEX USING HASH(gun_index),
					FOREIGN KEY (gun_index) REFERENCES pluto_items(idx) ON DELETE CASCADE
				)
			]]
		},
		{
			[[
				CREATE TABLE IF NOT EXISTS pluto_currency_tab (
					owner BIGINT UNSIGNED NOT NULL,
					currency VARCHAR(8) NOT NULL,
					amount INT UNSIGNED NOT NULL DEFAULT 0,
					PRIMARY KEY(owner, currency),
					INDEX USING HASH(owner)
				)
			]]
		},
	}:wait(true)
end)

hook.Add("CheckPassword", "pluto_db", function()
	RunConsoleCommand("sv_hibernate_think", GetConVar("sv_hibernate_think"):GetInt() + 1)
	pluto.db.db:ping()
	RunConsoleCommand("sv_hibernate_think", GetConVar("sv_hibernate_think"):GetInt() - 1)
end)