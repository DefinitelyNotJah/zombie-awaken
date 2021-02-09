import React, { Component } from 'react';
import Backdrop from '@material-ui/core/Backdrop';
import CircularProgress from '@material-ui/core/CircularProgress';
import Configuration from './config.json';
import { withStyles } from '@material-ui/core/styles';
import Typography from '@material-ui/core/Typography';
import Paper from '@material-ui/core/Paper';
import DirectionsWalkIcon from '@material-ui/icons/DirectionsWalk';
import AndroidIcon from '@material-ui/icons/Android';
import MapIcon from '@material-ui/icons/Map';
import DnsIcon from '@material-ui/icons/Dns';
import Divider from '@material-ui/core/Divider';
import Table from '@material-ui/core/Table';
import TableBody from '@material-ui/core/TableBody';
import TableCell from '@material-ui/core/TableCell';
import TableContainer from '@material-ui/core/TableContainer';
import TableHead from '@material-ui/core/TableHead';
import TableRow from '@material-ui/core/TableRow';
import TextField from '@material-ui/core/TextField';
import Autocomplete from '@material-ui/lab/Autocomplete';

const useStyles = (theme) => ({
	backdrop: {
		zIndex: theme.zIndex.drawer + 1,
		color: '#fff',
	},
	PaperX: {
		marginLeft: theme.spacing(2),
		marginRight: theme.spacing(2),
		marginTop: theme.spacing(3),
		padding: theme.spacing(2, 3, 2)
	},
	imagineClass: {
		margin: theme.spacing(1, 2, 1),
		width: theme.spacing(80),
		height: theme.spacing(20),
		maxWidth: '100%',
		maxHeight: '100%',
		display: 'block',
		marginLeft: 'auto',
		marginRight: 'auto',
	},
	root: {
	    display: 'flex',
	    flexWrap: 'wrap',
	    marginTop: '1rem',
	    '& > *': {
			margin: theme.spacing(1),
			width: '23.7%',
			height: theme.spacing(16),
	    },
	},
	table: {
		minWidth: 650,
		marginTop: '1rem',
	},
	tablebody: {
		height: theme.spacing(50)
	},
	SearchBar: {
		width: theme.spacing(40)
	},
});

function CalculateRank(level) {
	switch(true)
	{
		case (level >= 5 && level < 10) : return 'Mortal'
		case (level >= 10 && level < 20): return 'Earth'
		case (level >= 20 && level < 30): return 'Sky'
		case (level >= 30 && level < 40): return 'Spirit'
		case (level >= 40 && level < 50): return 'Dream'
		case (level >= 50 && level < 60): return 'Dao'
		case (level >= 60 && level < 70): return 'Sage'
		case (level >= 70 && level < 80): return 'Exalted'
		case (level >= 80 && level < 90): return 'Ascending'
		case (level >= 90 && level < 95): return 'Immortal'
		case (level >= 95): return 'Beyond the Universe'
		default : return 'Nascent'
	}
}
class MainApp extends Component {
	constructor(props)
	{
		super(props)
		this.state = {
			loading : true,
			ArrayUsers : [],
			SearchBar : '',
			NumberofBots : 0,
			NumberofPlayers : 0,
			MapName : ''
		}
		this.HandleChange = this.HandleChange.bind(this);
	}
	HandleChange = (event) => {
		this.setState({ SearchBar : event.target.value })
	}
	componentDidMount()
	{
		fetch(Configuration.BACKEND_SERVER + 'game_info')
		.then(res => res.json())
		.then(json => {
			if(json.success)
			{
				this.setState({
					loading : false,
					ArrayUsers : json.TableUsers,
					NumberofBots : json.NumberofBots,
					NumberofPlayers : json.NumberofPlayers,
					MapName : json.MapName
				})
			}
		})
	}
	render () {
		const {
			loading,
			ArrayUsers,
			SearchBar,
			NumberofBots,
			NumberofPlayers,
			MapName
		} = this.state;
		const { classes }  = this.props;
		const FilteredArray = ArrayUsers.filter( (item) => {
			return item.name.toLowerCase().indexOf(SearchBar.toLowerCase()) !== -1;
		})
		return (
			<div>
				{
					loading ? (
						<div>
							<Backdrop className={classes.backdrop} open={loading}>
								<CircularProgress color="inherit" />
							</Backdrop>
						</div>
					) : null
				}
				<div>
					<img className={classes.imagineClass} src="http://gamerclub.net/forum/uploads/monthly_2019_04/Logo.png.4779ed8bbf7322c22eba2d946bf47f68.png" alt="Yeah" />
				</div>
				<div
					style={{
						width: '100%',
						height: '100%'
					}}
				>
					<Paper
						className={classes.PaperX}
					>
						<div
							style={{
								marginBottom: '1rem'
							}}
						>
							<Typography variant="h5" gutterBottom>
								Zombie CSO
							</Typography>
						</div>
						<Divider />
						<div className={classes.root}>
							<Paper
							 style={{
							 	padding: '1rem',
					 			display: 'flex',
								flexWrap: 'wrap'
							 }}
							>
								<div>
									<Typography variant="caption" display="block" gutterBottom>
										Online Players :
									</Typography>
									<Typography variant="h6" gutterBottom>
										{NumberofPlayers}
									</Typography>
								</div>
								<DirectionsWalkIcon style={{
										marginLeft: '90%'
								}} />
							</Paper >
							<Paper
							 style={{
							 	padding: '1rem',
					 			display: 'flex',
								flexWrap: 'wrap'
							 }}
							>
								<div>
									<Typography variant="caption" display="block" gutterBottom>
										Online Bots :
									</Typography>
									<Typography variant="h6" gutterBottom>
										{NumberofBots}
									</Typography>
								</div>
								<AndroidIcon style={{
										marginLeft: '90%'
								}} />
							</Paper >
							<Paper
							 style={{
							 	padding: '1rem',
					 			display: 'flex',
								flexWrap: 'wrap'
							 }}
							>
								<div>
									<Typography variant="caption" display="block" gutterBottom>
										Current Map :
									</Typography>
									<Typography variant="h6" gutterBottom>
										{MapName}
									</Typography>
								</div>
								<MapIcon style={{
										marginLeft: '90%'
								}} />
							</Paper >
							<Paper
								style={{
									padding: '1rem',
									display: 'flex',
									flexWrap: 'wrap'
								}}
							>
								<div>
									<Typography variant="caption" display="block" gutterBottom>
										IP Address :
									</Typography>
									<Typography variant="h6" gutterBottom>
										YOUR_IP
									</Typography>
								</div>
								<DnsIcon style={{
										marginLeft: '90%'
								}} />
							</Paper >
						</div>
					</Paper>
					<Paper
						className={classes.PaperX}
					>
						<div
							style={{
								marginBottom: '1rem'
							}}
						>
							<div>
								<Typography variant="h5" gutterBottom>
									Ranking
								</Typography>
							</div>
						</div>
						<Divider />
						<TableContainer component={Paper} className={classes.tablebody}>
							<Table stickyHeader className={classes.table} size="small" aria-label="a dense table">
								<TableHead>
									<TableRow>
										<TableCell align="left">#</TableCell>
										<TableCell>Player Name</TableCell>
										<TableCell align="right">Rank</TableCell>
										<TableCell align="right">Level</TableCell>
										<TableCell align="right">XP</TableCell>
										<TableCell align="right">Money</TableCell>
										<TableCell align="right">Infections</TableCell>
										<TableCell align="right">Kills</TableCell>
										<TableCell align="right">Deaths</TableCell>
										<TableCell align="right">K/D</TableCell>
									</TableRow>
								</TableHead>
								<TableBody>
									{FilteredArray.map((item, index) => (
										<TableRow key={index}>
											<TableCell align="left">{index+1}</TableCell>
											<TableCell component="th" scope="row">
												{item.name}
											</TableCell>
											<TableCell align="right">{CalculateRank(item.level)}</TableCell>
											<TableCell align="right">{item.level}</TableCell>
											<TableCell align="right">{item.xp}</TableCell>
											<TableCell align="right">${item.money}</TableCell>
											<TableCell align="right">{item.infections}</TableCell>
											<TableCell align="right">{item.kills}</TableCell>
											<TableCell align="right">{item.deaths}</TableCell>
											<TableCell align="right">{item.kills / item.deaths}</TableCell>
										</TableRow>
									))}
								</TableBody>
							</Table>
						</TableContainer>
						<div style={{
							marginRight: '1rem',
							height: '100%',
							width: '100%',
							display: 'flex',
							justifyContent: 'flex-end'
						}}>
							<Autocomplete
								freeSolo
								disableClearable
								options={ArrayUsers.map((option) => option.name)}
								className={classes.SearchBar}
								renderInput={(params) => (
									<TextField
										{...params}
										label="Search input"
										value={SearchBar}
										onChange={this.HandleChange}
										margin="normal"
										variant="outlined"
										className={classes.SearchBar}
										InputProps={{ ...params.InputProps, type: 'search' }}
									/>
								)}
							/>
						</div>
					</Paper>
				</div>
			</div>
		)
	}
}
export default withStyles(useStyles)(MainApp);