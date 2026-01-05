import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import 'package:pos_admin/constants/colors.dart';
import 'package:responsive_grid_list/responsive_grid_list.dart';

class OverAllReport extends StatefulWidget {
  const OverAllReport({Key? key}) : super(key: key);
  
  @override
  State<OverAllReport> createState() => _OverAllReportState();
}

class _OverAllReportState extends State<OverAllReport> {
  List items = [
    "Future orders",
    "Report Billwise",
    "Report Itemwise",
    "Report Datewise",
    "Report Cancelledbillwise",
    "Report Non Chargeable bill",
    "Report Departmentwise",
    "Report Customerwise",
    "Report Total summary"
  ];

  String search = '';
  @override
  Widget build(BuildContext context) {
    return MediaQuery.of(context).size.width < 600
        ? Column(
            children: [
              Stack(
                children: <Widget>[
                  Container(
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(50),
                      ),
                      color: black,
                    ),
                    width: double.infinity,
                    height: MediaQuery.of(context).size.height / 3.5,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 22),
                      child: Lottie.asset(
                        "$lottiePath/bill.json",
                        fit: BoxFit.fitHeight,
                        frameRate: FrameRate(90),
                      ),
                    ),
                  ), //Container
                  //Container
                  Container(
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(50),
                      ),
                      color: primaryColor,
                    ),
                    height: MediaQuery.of(context).size.height / 20,
                    width: double.infinity,
                  ), //Container
                ], //<Widget>[]
              ),
              // SizedBox(
              //   height: MediaQuery.of(context).size.height / 80,
              // ),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('Bills')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                          child: CircularProgressIndicator(
                        color: primaryColor,
                      ));
                    }

                    if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    }

                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Text('No data available');
                    }

                    return ListView.builder(
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        var billData = snapshot.data!.docs[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 6),
                          child: GestureDetector(
                            onTap: () {
                              // Navigator.push(
                              //     context,
                              //     MaterialPageRoute(
                              //         builder: (context) =>
                              //             BillDetailsScreen(billData: billData)));
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Container(
                                height: MediaQuery.of(context).size.height / 6,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(color: green)),
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 5),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        flex: 2,
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Container(
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .height /
                                                  10,
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width /
                                                  4,
                                              decoration: BoxDecoration(
                                                  border:
                                                      Border.all(color: green),
                                                  shape: BoxShape.circle,
                                                  color: Colors.green.shade100),
                                              child: Center(
                                                child: Lottie.asset(
                                                  "$lottiePath/bill2.json",
                                                  fit: BoxFit.fitHeight,
                                                  frameRate: FrameRate(90),
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .height /
                                                  100,
                                            ),
                                            Text(
                                              'Bill-${index + 1}',
                                              style: const TextStyle(
                                                  fontFamily: 'tabfont',
                                                  fontSize: 17),
                                            )
                                          ],
                                        ),
                                      ),
                                      Expanded(
                                        flex: 4,
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            RichText(
                                              text: TextSpan(
                                                text: 'User ID: ',
                                                style: const TextStyle(
                                                    fontFamily: 'fontmain',
                                                    color: black,
                                                    fontSize: 14),
                                                children: <TextSpan>[
                                                  TextSpan(
                                                    text:
                                                        '${billData['userId']}',
                                                    style: const TextStyle(
                                                      color: black,
                                                      fontFamily:
                                                          'fontmain', // Customize the color
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            SizedBox(
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .height /
                                                  120,
                                            ),
                                            const Text(
                                              'Tap here to see more information',
                                              style: TextStyle(
                                                  color: grey,
                                                  fontFamily: 'fontmain'),
                                            )
                                          ],
                                        ),
                                      ),
                                      Expanded(
                                        child: Container(
                                          decoration: const BoxDecoration(
                                            color: Color.fromARGB(
                                                255, 129, 191, 202),
                                            borderRadius: BorderRadius.only(
                                              topRight: Radius.circular(19.0),
                                              bottomRight:
                                                  Radius.circular(19.0),
                                            ),
                                          ),
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height /
                                              6,
                                          child: const Icon(
                                            Icons.arrow_forward_ios,
                                            color: white,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          )
        : SizedBox(
            child: Column(
            children: [
              Container(
                width: MediaQuery.of(context).size.width -
                    MediaQuery.of(context).size.width / 6,
                height: 55,
                decoration: BoxDecoration(
                  color: Colors.white,

                  boxShadow: [
                    BoxShadow(
                        color: Colors.grey.withOpacity(0.8),
                        spreadRadius: 0.5,
                        blurRadius: 0.5)
                  ],
                  // boxShadow: [
                  //   BoxShadow(color: Colors.grey.withOpacity(0.3), spreadRadius: 1, blurRadius: 1)
                  // ]
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(left: 40),
                          child: Text("customer's List",
                              style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 21)),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 41),
                      child: Container(
                        height: 45,
                        width: 290,
                        decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(0.1),
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.grey.withOpacity(0.1),
                                  spreadRadius: 0.4,
                                  blurRadius: 0.4)
                            ],
                            borderRadius: BorderRadius.circular(21)),
                        child: Padding(
                          padding: const EdgeInsets.only(
                              left: 21, right: 11, bottom: 6),
                          child: TextField(
                            onChanged: (value) {
                              search = value;
                              setState(() {});
                            },
                            inputFormatters: [
                              LengthLimitingTextInputFormatter(10),
                              //FilteringTextInputFormatter.digitsOnly,
                            ],
                            // controller: phone,
                            decoration: const InputDecoration(
                                suffixIcon: Icon(
                                  Icons.search,
                                  color: Colors.grey,
                                ),
                                border: InputBorder.none,
                                hintText: "search here....",
                                hintStyle: TextStyle(color: Colors.grey)),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 21,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 43),
                child: SizedBox(
                  height: 30,
                  child: ListView.builder(
                      itemCount: items.length,
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (c, index) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 25),
                          child: Container(
                            height: 30,
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                            //padding: const EdgeInsets.symmetric(horizontal: 9,vertical: 5),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(6),
                                color:
                                     primaryColor.withOpacity(0.4)),
                            child: Center(
                              child: Text(items[index],
                                  style: TextStyle(
                                      color: primaryColor,
                                      fontWeight: FontWeight.w400,
                                      fontSize: 13)),
                            ),
                          ),
                        );
                      }),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                child: Container(
                  height: 55,
                  width: MediaQuery.of(context).size.width -
                      MediaQuery.of(context).size.width / 6,
                  decoration: BoxDecoration(
                    color:  primaryColor,
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Container(
                        height: 40,
                        width: 40,
                        decoration: BoxDecoration(
                          color:primaryColor,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Center(
                          child: Text(
                            "No.",
                            //textAlign: TextAlign.center,
                            //maxLines: 2,
                            style: TextStyle(
                                // fontFamily: 'fontmain',
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 16),
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 140,
                        child: Text(
                          'User Id',
                          //textAlign: TextAlign.center,
                          //maxLines: 2,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 120,
                        height: 20,
                        child: Text(
                          "Created At",
                          //textAlign: TextAlign.center,
                          //maxLines: 2,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 140,
                        child: Text(
                          "Admin Id",
                          //textAlign: TextAlign.center,
                          //maxLines: 2,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 80,
                        height: 20,
                        child: Text(
                          'Total Amount',
                          //textAlign: TextAlign.center,
                          //maxLines: 2,
                          style: TextStyle(
                            // fontFamily: 'fontmain',
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            //letterSpacing: 1.2,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 40, top: 21, right: 40),
                  child: StreamBuilder(
                      stream: FirebaseFirestore.instance
                          .collection('Bills')
                          .snapshots(),
                      builder: (context,
                          AsyncSnapshot<QuerySnapshot> streamSnapshot) {
                        if (streamSnapshot.hasData) {
                          return ResponsiveGridList(
                              horizontalGridSpacing: 6,
                              horizontalGridMargin: 0,
                              minItemWidth: 450,
                              minItemsPerRow: 1,
                              maxItemsPerRow: 1,
                              listViewBuilderOptions: ListViewBuilderOptions(),
                              children: List.generate(
                                  streamSnapshot.data!.docs.length, (index) {
                                final DocumentSnapshot documentSnapshot =
                                    streamSnapshot.data!.docs[index];
                                //ids.add();
                                if (documentSnapshot['subTotal']
                                        .toString()
                                        .contains(search) ||
                                    documentSnapshot['createdAt']
                                        .toString()
                                        .contains(search)) {
                                  return Container(
                                    height: 55,
                                    width: MediaQuery.of(context).size.width -
                                        MediaQuery.of(context).size.width / 6,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(9),
                                      boxShadow: [
                                        BoxShadow(
                                            color: Colors.grey.withOpacity(0.5),
                                            spreadRadius: 0.5,
                                            blurRadius: 0.5)
                                      ],
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      children: [
                                        Container(
                                          height: 40,
                                          width: 40,
                                          decoration: BoxDecoration(
                                            color:  primaryColor,
                                            borderRadius:
                                                BorderRadius.circular(20),
                                          ),
                                          child: Center(
                                            child: Text(
                                              (index + 1).toString(),
                                              //textAlign: TextAlign.center,
                                              //maxLines: 2,
                                              style: const TextStyle(
                                                // fontFamily: 'fontmain',
                                                color: Colors.white,
                                                fontWeight: FontWeight.w600,
                                                //letterSpacing: 1.2,
                                                fontSize: 17,
                                              ),
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          width: 140,
                                          child: Text(
                                            documentSnapshot['userId'],
                                            //textAlign: TextAlign.center,
                                            //maxLines: 2,
                                            style: const TextStyle(
                                              // fontFamily: 'fontmain',
                                              color: Colors.grey,
                                              fontWeight: FontWeight.w500,
                                              //letterSpacing: 1.2,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          width: 120,
                                          height: 20,
                                          child: Text(
                                            documentSnapshot['createdAt'],
                                            //textAlign: TextAlign.center,
                                            //maxLines: 2,
                                            style: const TextStyle(
                                              // fontFamily: 'fontmain',
                                              color: Colors.black,
                                              fontWeight: FontWeight.w600,
                                              //letterSpacing: 1.2,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          width: 140,
                                          child: Text(
                                            documentSnapshot['adminId'],
                                            //textAlign: TextAlign.center,
                                            //maxLines: 2,
                                            style: const TextStyle(
                                              // fontFamily: 'fontmain',
                                              color: Colors.grey,
                                              fontWeight: FontWeight.w500,
                                              //letterSpacing: 1.2,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          width: 80,
                                          height: 20,
                                          child: Row(
                                            children: [
                                              const Text(
                                                'Rs ',
                                                //textAlign: TextAlign.center,
                                                //maxLines: 2,
                                                style: TextStyle(
                                                  // fontFamily: 'fontmain',
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.w600,
                                                  //letterSpacing: 1.2,
                                                  fontSize: 16,
                                                ),
                                              ),
                                              Text(
                                                documentSnapshot['subTotal']
                                                    .toString(),
                                                //textAlign: TextAlign.center,
                                                //maxLines: 2,
                                                style: const TextStyle(
                                                  // fontFamily: 'fontmain',
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.w600,
                                                  //letterSpacing: 1.2,
                                                  fontSize: 16,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                } else {
                                  return const SizedBox(
                                    height: 0,
                                  );
                                }
                              }));
                        } else {
                          return const Center(
                              child: CircularProgressIndicator());
                        }
                      }),
                ),
              ),
            ],
          ));
  }
}
