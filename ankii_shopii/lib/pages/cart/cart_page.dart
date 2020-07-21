import 'dart:async';

import 'package:ankiishopii/blocs/cart_bloc/bloc.dart';
import 'package:ankiishopii/blocs/cart_bloc/event.dart';
import 'package:ankiishopii/blocs/cart_bloc/state.dart';
import 'package:ankiishopii/models/ordering_model.dart';
import 'package:ankiishopii/models/product_model.dart';
import 'package:ankiishopii/themes/constant.dart';
import 'package:ankiishopii/widgets/app_bar.dart';
import 'package:ankiishopii/widgets/debug_widget.dart';
import 'package:ankiishopii/widgets/product_item.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CartPage extends StatefulWidget {
  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  CartBloc bloc;
  ScrollController _scrollController = ScrollController();
  StreamController _scrollStreamController = StreamController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    bloc = BlocProvider.of<CartBloc>(context);
//    _scrollController.addListener(() {
//      bool isScrollUp = _scrollController.position.userScrollDirection == ScrollDirection.reverse;
//      _scrollStreamController.sink.add(isScrollUp);
//    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _scrollStreamController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BACKGROUND_COLOR,
      body: BlocBuilder(
          bloc: bloc,
          builder: (context, state) {
            if (state is CartLoaded) {
              return Column(
                children: <Widget>[
                  Expanded(
                    child: Container(
                      child: SingleChildScrollView(
                        controller: _scrollController,
                        child: Column(
                          children: <Widget>[buildAppBar(), buildCartDetail(state.cart.orderingDetail)],
                        ),
                      ),
                    ),
                  ),
                  buildNavigation(state.cart)
                ],
              );
            } else if (state is CartError) {
              return Center(
                child: CustomErrorWidget(),
              );
            } else {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
          }),
    );
  }

  Widget buildNavigation(OrderingModel cart) {
    if (cart.orderingDetail.length > 0) {
      int total = 0;
      for (var od in cart.orderingDetail) {
        var eachTotal = od.count * od.product.price;
        total += eachTotal;
      }
      return StreamBuilder(
          stream: _scrollStreamController.stream,
          builder: (context, snapshot) {
            return AnimatedContainer(
              duration: Duration(milliseconds: 100),
              decoration: BoxDecoration(
                  color: BACKGROUND_COLOR,
                  boxShadow: [BoxShadow(color: Colors.black26, offset: Offset(0, -3), blurRadius: 3)]),
              height: snapshot.hasData && snapshot.data == true ? 0 : 55,
              child: Row(
                children: <Widget>[
                  Expanded(
                      child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(
                          'Total:',
                          style: DEFAULT_TEXT_STYLE.copyWith(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          total.toString() + "d",
                          style: DEFAULT_TEXT_STYLE.copyWith(
                              fontWeight: FontWeight.bold, fontSize: 20, color: Colors.redAccent),
                        )
                      ],
                    ),
                  )),
                  GestureDetector(
                    onTap: () {},
                    child: Container(
                      padding: EdgeInsets.all(10),
                      height: 55,
                      width: 110,
                      color: FOREGROUND_COLOR,
                      child: Icon(
                        Icons.forward,
                        size: 25,
                      ),
                    ),
                  )
                ],
              ),
            );
          });
    }
    return Container();
  }

  Widget buildAppBar() {
    return InPageAppBar(
      title: 'Cart',
      showCartButton: false,
      leading: GestureDetector(
        onTap: () {
          Navigator.pop(context);
        },
        child: Icon(Icons.arrow_back_ios),
      ),
    );
  }

  Widget buildCartDetail(List<OrderingDetailModel> orderingDetail) {
    if (orderingDetail.length > 0) {
      return Container(
        child: Column(
          children: orderingDetail.map<Widget>((od) {
            var product = od.product;
            return CustomProductCartItem(
              onDelete: () {
                _removeFromCartConfirmDialog(
                    product: product,
                    onYes: () {
                      bloc.add(AddToCart(productID: product.id, count: od.count * -1));
                    });
              },
              onIncreaseQuantity: () {
                bloc.add(AddToCart(productID: product.id, count: 1));
              },
              onDecreaseQuantity: () {
                if (od.count - 1 <= 0) {
                  _removeFromCartConfirmDialog(
                      product: product,
                      onYes: () {
                        bloc.add(AddToCart(productID: product.id, count: -1));
                      });
                } else {
                  bloc.add(AddToCart(productID: product.id, count: -1));
                }
              },
              backgroundColor: FOREGROUND_COLOR,
              cartItem: od,
            );
          }).toList()
            ..add(Container(
              height: 60,
            )),
        ),
      );
    }
    return Center(
      child: Text('Nothing here :)'),
    );
  }

  _removeFromCartConfirmDialog({@required ProductModel product, @required Function onYes}) {
    showDialog(
        context: context,
        builder: (_) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25), side: BorderSide(color: FOREGROUND_COLOR, width: 2)),
            backgroundColor: BACKGROUND_COLOR,
            title: Text(product.name),
            content: Text('You wanna remove this item from cart?'),
            actions: <Widget>[
              FlatButton(
                  onPressed: () {
                    onYes();
                    Navigator.pop(context);
                  },
                  child: Text('Yes')),
              FlatButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text(
                    'No',
                    style: DEFAULT_TEXT_STYLE.copyWith(fontWeight: FontWeight.bold),
                  )),
            ],
          );
        });
  }
}