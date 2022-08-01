import 'package:experience/models/championship.dart';
import 'package:experience/models/country.dart';
import 'package:experience/models/sport.dart';
import 'package:experience/models/match.dart';
import 'package:experience/models/user.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DbHelper {
  DbHelper._createInstance();

  String db_name = "experience.db";

  static Database _database;
  static DbHelper helper;

  String country_table = "country_table";
  String col_country_id = "id";
  String col_country_name = "name";
  String col_country_name_en = "name_en";
  String col_country_sport_id = "sport_id";

  String sport_table = "sport_table";
  String col_sport_id = "id";
  String col_sport_name = "name";

  String user_match_table = "user_match_table";
  String col_user_match_id = "id";
  String col_user_opp1_name = "opp1_name";
  String col_user_opp2_name = "opp2_name";
  String col_user_opp1_icon = "opp1_icon";
  String col_user_opp2_icon = "opp2_icon";
  String col_user_opp1_odds = "opp1_odds";
  String col_user_opp2_odds = "opp2_odds";
  String col_user_match_date = "match_date";
  String col_user_winner = "winner";
  String col_user_loser = "loser";
  String col_user_selected_team = "selected_team";

  String match_table = "match_table";
  String col_match_id = "id";
  String col_opp1_name = "opp1_name";
  String col_opp2_name = "opp2_name";
  String col_opp1_icon = "opp1_icon";
  String col_opp2_icon = "opp2_icon";
  String col_opp1_odds = "opp1_odds";
  String col_opp2_odds = "opp2_odds";
  String col_match_date = "match_date";
  String col_winner = "winner";
  String col_loser = "loser";
  String col_selected_team = "selected_team";

  String championship_table = "championship_table";
  String col_champ_id = "id";
  String col_champ_sport_id = "sport_id";
  String col_champ_country_id = "country_id";
  String col_champ_sport = "sport";
  String col_champ_country = "country";
  String col_champ_name = "name";
  String col_champ_name_en = "name_en";

  String user_table = "user_table";
  String col_user_profile_picture = "profile_picture";
  String col_user_nickname = "nickname";
  String col_user_points = "points";

  factory DbHelper(){
    helper ??= DbHelper._createInstance();
    return helper;
  }

  Future<Database> get database async {
    _database ??= await initializeDatabase();
    return _database;
  }

  Future createDb(Database db, int version) async {

    String create_user_table = "create table $user_table ("
        "$col_user_profile_picture text,"
        "$col_user_nickname text,"
        "$col_user_points double)";

    String create_champ_table = "create table $championship_table ("
        "$col_champ_id integer,"
        "$col_champ_sport_id integer,"
        "$col_champ_country_id integer,"
        "$col_champ_sport text,"
        "$col_champ_country text,"
        "$col_champ_name text,"
        "$col_champ_name_en text)";

    String create_match_table = "create table $match_table ("
        "$col_match_id integer,"
        "$col_opp1_name text,"
        "$col_opp2_name text,"
        "$col_opp1_icon text,"
        "$col_opp2_icon text,"
        "$col_opp1_odds double,"
        "$col_opp2_odds double,"
        "$col_match_date text,"
        "$col_winner text,"
        "$col_loser text,"
        "$col_selected_team text)";

    String create_user_match_table = "create table $user_match_table ("
        "$col_user_match_id integer,"
        "$col_user_opp1_name text,"
        "$col_user_opp2_name text,"
        "$col_user_opp1_icon text,"
        "$col_user_opp2_icon text,"
        "$col_user_opp1_odds double,"
        "$col_user_opp2_odds double,"
        "$col_user_match_date text,"
        "$col_user_winner text,"
        "$col_user_loser text,"
        "$col_selected_team text)";

    String create_country_table = "create table $country_table ("
        "$col_country_id integer,"
        "$col_country_name text,"
        "$col_country_name_en text,"
        "$col_country_sport_id text)";

    String create_sport_table = "create table $sport_table ("
        "$col_sport_id integer,"
        "$col_sport_name text)";

    await db.execute(create_user_table);
    await db.execute(create_user_match_table);
    await db.execute(create_champ_table);
    await db.execute(create_match_table);
    await db.execute(create_country_table);
    await db.execute(create_sport_table);

  }

  Future<void> deleteChampionships() async {
    Database db = await database;
    String query = "delete from $championship_table";
    await db.execute(query);
  }

  Future<void> deleteCountries() async {
    Database db = await database;
    String query = "delete from $country_table";
    await db.execute(query);
  }

  Future<void> deleteMatches() async {
    Database db = await database;
    String query = "delete from $match_table";
    await db.execute(query);
  }

  Future<void> deleteSports() async {
    Database db = await database;
    String query = "delete from $sport_table";
    await db.execute(query);
  }

  Future<void> deleteUser() async {
    Database db = await database;
    String query = "delete from $user_table";
    await db.execute(query);
  }

  Future<void> deleteUserMatch(int id) async {
    Database db = await database;
    String query = "delete from $user_match_table where $col_user_match_id=$id";
    await db.execute(query);
  }

  Future<List<Championship>> getChampionships(int sport_id) async {
    List<Championship> list = [];
    Database db = await database;
    String query = "select * from $championship_table where $col_champ_sport_id=$sport_id";
    List<Map<String, Object>> result = await db.rawQuery(query);
    for(var i = 0; i<result.length; i++){
      Championship c = Championship(
        id: result[i][col_champ_id],
        sport_id: result[i][col_champ_sport_id],
        country_id: result[i][col_champ_country_id],
        sport: result[i][col_champ_sport],
        country: result[i][col_champ_country],
        name: result[i][col_champ_name],
        name_en: result[i][col_champ_name_en],
      );
      list.add(c);
    }
    return list;
  }

  Future<List<Country>> getCountries() async {
    List<Country> list = [];
    Database db = await database;
    String query = "select * from $country_table";
    List<Map<String, Object>> result = await db.rawQuery(query);
    for(var i = 0; i<result.length; i++){
      Country c = Country(
        id: result[i][col_country_id],
        name: result[i][col_country_name],
        name_en: result[i][col_country_name_en],
        sport_id: result[i][col_country_sport_id],
        is_selected: false,
      );
      list.add(c);
    }
    print("db_helper.getCountries list size is ${list.length}");
    return list;
  }

  Future<List<Match>> getMatches() async {
    List<Match> list = [];
    Database db = await database;
    String query = "select * from $match_table";
    List<Map<String, Object>> result = await db.rawQuery(query);
    for(var i = 0; i<result.length; i++){
      Match m = Match(
        id: result[i][col_match_id],
        opp1_name: result[i][col_opp1_name],
        opp2_name: result[i][col_opp2_name],
        opp1_icon: result[i][col_opp1_icon],
        opp2_icon: result[i][col_opp2_icon],
        opp1_odds: result[i][col_opp1_odds],
        opp2_odds: result[i][col_opp2_odds],
        match_date: result[i][col_match_date],
        winner: result[i][col_winner],
        loser: result[i][col_loser],
        selected_team: result[i][col_selected_team],
      );
      list.add(m);
    }
    return list;
  }

  Future<List<Sport>> getSports() async {
    List<Sport> list = [];
    Database db = await database;
    String query = "select * from $sport_table";
    List<Map<String, Object>> result = await db.rawQuery(query);
    for(var i = 0; i<result.length; i++){
      Sport s = Sport(
        id: result[i][col_sport_id],
        name: result[i][col_sport_name],
        is_selected: false,
      );
      list.add(s);
    }
    return list;
  }

  Future<User> getUser() async {
    User user;
    Database db = await database;
    String query = "select * from $user_table";
    List<Map<String, Object>> result = await db.rawQuery(query);
    if(result.isEmpty){
      user = User(
        nickname: "",
        profile_picture: "",
        points: 0
      );
    }
    else{
      for(var i = 0; i<result.length; i++){
        user = User(
            nickname: result[i][col_user_nickname]??"",
            profile_picture: result[i][col_user_profile_picture]??"",
            points: result[i][col_user_points]??0
        );
      }
    }
    return user;
  }

  Future<List<Match>> getUserMatches() async {
    List<Match> list = [];
    Database db = await database;
    String query = "select * from $user_match_table";
    List<Map<String, Object>> result = await db.rawQuery(query);
    for(var i = 0; i<result.length; i++){
      Match m = Match(
        id: result[i][col_user_match_id],
        opp1_name: result[i][col_user_opp1_name],
        opp2_name: result[i][col_user_opp2_name],
        opp1_icon: result[i][col_user_opp1_icon],
        opp2_icon: result[i][col_user_opp2_icon],
        opp1_odds: result[i][col_user_opp1_odds],
        opp2_odds: result[i][col_user_opp2_odds],
        match_date: result[i][col_user_match_date],
        winner: result[i][col_user_winner],
        loser: result[i][col_user_loser],
        selected_team: result[i][col_user_selected_team],
      );
      list.add(m);
    }
    return list;
  }

  Future<Database> initializeDatabase() async{
    final db_path = await getDatabasesPath();
    final path = join(db_path, db_name);
    return await openDatabase(path, version: 1, onCreate: createDb);
  }

  Future<void> saveChampionships(List<Championship> championships) async {
    Database db = await database;
    for(var i = 0; i<championships.length; i++){
      Championship c = championships[i];
      String query = "insert into $championship_table ($col_champ_id, $col_champ_sport_id, "
          "$col_champ_country_id, $col_champ_sport, $col_champ_country, $col_champ_name, "
          "$col_champ_name_en) values (${c.id}, ${c.sport_id}, ${c.country_id}, "
          "'${c.sport}', '${c.country}', '${c.name}', '${c.name_en}')";
      try{
        await db.execute(query);
      }
      catch(e){

      }
    }
  }

  Future<void> saveCountries(List<Country> countries) async {
    print("db_helper.saveCountries countries list length is ${countries.length}");
    Database db = await database;
    for(var i = 0; i<countries.length; i++){
      Country c = countries[i];
      String query = "insert into $country_table ($col_country_id, $col_country_name, "
          "$col_country_name_en, $col_sport_id) values (${c.id}, '${c.name}', '${c.name_en}',"
          "'${c.sport_id}')";
      await db.execute(query);
    }
  }

  Future<void> saveUser(User user) async {
    Database db = await database;
    String query = "insert into $user_table ("
        "$col_user_nickname, $col_user_profile_picture, $col_user_points) values ("
        "'${user.nickname}', '${user.profile_picture}', ${user.points})";
    await db.execute(query);
  }

  Future<void> saveUserMatch(Match m) async {
    Database db = await database;
    String query = "insert into $user_match_table ("
        "$col_user_match_id, $col_user_opp1_name, $col_user_opp2_name, $col_user_opp1_icon, $col_user_opp2_icon, "
        "$col_user_opp1_odds, $col_user_opp2_odds, $col_user_match_date, $col_user_winner, $col_user_loser, $col_selected_team) values ("
        "${m.id}, '${m.opp1_name}', '${m.opp2_name}', '${m.opp1_icon}', '${m.opp2_icon}', "
        "${m.opp1_odds}, ${m.opp2_odds}, '${m.match_date}', '${m.winner}', '${m.loser}', '${m.selected_team}')";
    await db.execute(query);
  }

  Future<void> saveMatches(List<Match> matches) async {
    //print("db_helper.saveMatches match list length is ${matches.length}");
    Database db = await database;
    for(var i = 0; i<matches.length; i++){
      Match m = matches[i];
      String query = "insert into $match_table ("
          "$col_match_id, $col_opp1_name, $col_opp2_name, $col_opp1_icon, $col_opp2_icon, "
          "$col_opp1_odds, $col_opp2_odds, $col_match_date, $col_winner, $col_loser, $col_selected_team) values ("
          "${m.id}, '${m.opp1_name}', '${m.opp2_name}', '${m.opp1_icon}', '${m.opp2_icon}', "
          "${m.opp1_odds}, ${m.opp2_odds}, '${m.match_date}', '${m.winner}', '${m.loser}', '${m.selected_team}')";
      await db.execute(query);
    }
  }

  Future<void> saveSports(List<Sport> sports) async {
    //print("db_helper.saveSports sports list length is ${sports.length}");
    Database db = await database;
    for(var i = 0; i<sports.length; i++){
      Sport s = sports[i];
      String query = "insert into $sport_table ($col_sport_id, $col_sport_name) "
          "values (${s.id}, '${s.name}')";
      await db.execute(query);
    }
  }

}