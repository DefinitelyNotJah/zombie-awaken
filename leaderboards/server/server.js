const express = require('express');
const mysql = require('mysql');
const app = express()
const port = 5000;
const cors = require('cors');

const Gamedig = require('gamedig');

app.use(cors());

app.listen(port, () => {
	console.log(`listening on port ${port}`);
});

app.get('/game_info', (req, res, next) => {
	var con = mysql.createConnection({
		host: "127.0.0.1",
		user: "root",
		password: "",
		database: "levels"
	});
	con.connect((err) => {
		if (err) 
		{
			console.log(err);
			return res.send({
				success : false,
				message : 'A server error as occured.'
			})
		}
		con.query("SELECT * FROM my_table", (err, result, fields) => {
			if (err) 
			{
				console.log(err);
				return res.send({
					success : false,
					message : 'A server error as occured.'
				})
			}
			var NewArray = []
			for(var i = 0; i < result.length; i++)
			{
				NewArray.push({
					name : result[i].NAME,
					level : result[i].Level,
					money : result[i].MONEY,
					skin : result[i].SKIN,
					knife : result[i].KNIFE,
					xp : result[i].XP
				})
			}
			NewArray.sort( (a, b) => {
				return b.level - a.level;
			})
			Gamedig.query({
				type: 'cs16',
				host: '127.0.0.1'
			}).then((state) => {
				return res.send({
					success : true,
					TableUsers : NewArray,
					NumberofBots : state.bots.length,
					NumberofPlayers : state.players.length,
					MapName : state.map
				})
			}).catch((error) => {
				return res.send({
					success : true,
					TableUsers : NewArray,
					NumberofBots : 0,
					NumberofPlayers : 0,
					MapName : "Server Offline"
				})
			});
		});
	});
})