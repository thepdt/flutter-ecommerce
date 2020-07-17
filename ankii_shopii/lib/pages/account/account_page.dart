import 'package:ankiishopii/blocs/account_bloc/bloc.dart';
import 'package:ankiishopii/blocs/account_bloc/event.dart';
import 'package:ankiishopii/blocs/account_bloc/state.dart';
import 'package:ankiishopii/blocs/login_bloc/service.dart';
import 'package:ankiishopii/helpers/media_query_helper.dart';
import 'package:ankiishopii/models/account_model.dart';
import 'package:ankiishopii/pages/account/login_page.dart';
import 'package:ankiishopii/themes/constant.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AccountPage extends StatefulWidget {
  final ScrollController scrollController;

  AccountPage(this.scrollController);

  @override
  _AccountPageState createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  AccountBloc bloc = AccountBloc(AccountLoading())..add(GetLocalAccount());

  @override
  void dispose() {
    // TODO: implement dispose
    bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BACKGROUND_COLOR,
      body: BlocBuilder(
          bloc: bloc,
          builder: (context, state) {
            if (state is AccountLoaded) {
              return Stack(
                children: <Widget>[
                  buildAvatar(),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child:
                        SingleChildScrollView(controller: widget.scrollController, child: buildProfile(state.account)),
                  )
                ],
              );
            } else if (state is AccountLoadingFailed) {
              return Center(child: buildLogInButton());
            } else {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
          }),
    );
  }

  Widget buildAvatar() {
    return Container(
      padding: EdgeInsets.all(30),
      alignment: Alignment.topCenter,
      decoration: BoxDecoration(color: FOREGROUND_COLOR),
      child: CircleAvatar(
        radius: 70,
        backgroundImage: NetworkImage(
            'https://upload.wikimedia.org/wikipedia/vi/thumb/b/b0/Avatar-Teaser-Poster.jpg/220px-Avatar-Teaser-Poster.jpg'),
      ),
    );
  }

  Widget buildProfile(AccountModel account) {
    return Column(
      children: <Widget>[
        Container(
          constraints: BoxConstraints(minHeight: ScreenHelper.getHeight(context) * 0.7),
          margin: EdgeInsets.only(top: 200),
          padding: EdgeInsets.only(top: 50, bottom: 50, left: 20, right: 20),
          decoration: BoxDecoration(
              boxShadow: [BoxShadow(color: Colors.black38, offset: Offset(0, -3), blurRadius: 5)],
              color: BACKGROUND_COLOR,
              borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20))),
          child: Column(
            children: <Widget>[
              _buildInfoItem(key: 'Username', value: account.username),
              Container(
                color: PRIMARY_COLOR.withOpacity(0.3),
                height: 1.5,
                margin: EdgeInsets.symmetric(vertical: 10),
              ),
              _buildInfoItem(key: 'Full Name', value: account.fullname),
              Container(
                color: PRIMARY_COLOR.withOpacity(0.3),
                height: 1.5,
                margin: EdgeInsets.symmetric(vertical: 10),
              ),
              _buildInfoItem(key: 'Phone', value: account.phoneNumber),
              Container(
                color: PRIMARY_COLOR.withOpacity(0.3),
                height: 1.5,
                margin: EdgeInsets.symmetric(vertical: 10),
              ),
              _buildInfoItem(key: 'Address', value: account.address),
              SizedBox(
                height: 50,
              ),
              buildLogoutButton()
            ],
          ),
        )
      ],
    );
  }

  Widget _buildInfoItem({String key, String value}) {
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            key ?? '',
          ),
          Text(
            value ?? '<empty>',
            style: DEFAULT_TEXT_STYLE.copyWith(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget buildLogInButton() {
    return RaisedButton(
      elevation: 0,
      onPressed: () async {
        await Navigator.push(context, MaterialPageRoute(builder: (b) => LoginPage()));
        bloc.add(GetLocalAccount());
      },
      color: FOREGROUND_COLOR,
      child: Container(
        child: Text('Log In'),
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
    );
  }

  Widget buildLogoutButton() {
    return RaisedButton(
      elevation: 0,
      onPressed: () async {
        await LoginService().logOut();
        bloc.add(GetLocalAccount());
      },
      color: FOREGROUND_COLOR,
      child: Container(
        child: Text('Log Out'),
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
    );
  }
}
