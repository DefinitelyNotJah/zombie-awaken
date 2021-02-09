# Leaderboards
Leaderboards made for Zombie Awaken using Node.JS for backend, React.JS and Material.UI for Frontend
![alt text](https://media.discordapp.net/attachments/666667003041284116/709581833502982204/Screenshot_from_2020-05-12_02-44-40.png "Leaderboards")
## Setup
Just go to `./server/server.js` and change the MySQL credentials info respectively there => 
```Javascript
	var con = mysql.createConnection({
		host: "127.0.0.1",
		user: "root",
		password: "",
		database: "levels"
	});
```