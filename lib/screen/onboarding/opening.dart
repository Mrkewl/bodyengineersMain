import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class OpeningPage extends StatefulWidget {
  @override
  _OpeningPageState createState() => _OpeningPageState();
}

class _OpeningPageState extends State<OpeningPage> {
  final int _numPages = 3;
  final PageController _pageController = PageController(initialPage: 0);
  int _currentPage = 0;

  List<Widget> _buildPageIndicator() {
    List<Widget> list = [];
    for (int i = 0; i < _numPages; i++) {
      list.add(i == _currentPage ? _indicator(true) : _indicator(false));
    }
    return list;
  }

  Widget _indicator(bool isActive) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 150),
      margin: EdgeInsets.symmetric(horizontal: 8.0),
      height: 8.0,
      width: isActive ? 8 : 8,
      decoration: BoxDecoration(
        color: isActive ? Color.fromRGBO(8, 112, 138, 1) : Colors.grey[400],
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 15),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Container(
                padding: EdgeInsets.symmetric(horizontal: 30),
                child: Image.asset('assets/images/onboarding/logo.png'),
              ),
              Container(
                height: MediaQuery.of(context).size.height * 0.5,
                child: PageView(
                  physics: ClampingScrollPhysics(),
                  controller: _pageController,
                  onPageChanged: (int page) {
                    setState(() {
                      _currentPage = page;
                    });
                  },
                  children: <Widget>[
                    Container(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Pick A Program',
                              style: TextStyle(
                                fontFamily: 'Lato',
                                fontSize: 24,
                              )),
                          SizedBox(height: 3),
                          Text(
                            'That fit your goals',
                            style: TextStyle(
                              fontFamily: 'Lato',
                              fontSize: 15,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            child: Container(
                              child: Image.asset(
                                'assets/images/onboarding/opening1.png',
                                height:
                                    MediaQuery.of(context).size.height * 0.30,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Sync Your Devices',
                            style: TextStyle(
                              fontFamily: 'Lato',
                              fontSize: 24,
                            ),
                          ),
                          SizedBox(height: 3),
                          Text(
                            'Integrate your lifestyle',
                            style: TextStyle(
                              fontFamily: 'Lato',
                              fontSize: 15,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            child: Container(
                              child: Image.asset(
                                'assets/images/onboarding/opening2.png',
                                height:
                                    MediaQuery.of(context).size.height * 0.30,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Personal Trainer in Your Pocket',
                            style: TextStyle(
                              fontFamily: 'Lato',
                              fontSize: 24,
                            ),
                          ),
                          Text(
                            'Hit your fitness milestones',
                            style: TextStyle(
                              fontFamily: 'Lato',
                              fontSize: 15,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            child: Container(
                              child: Image.asset(
                                'assets/images/onboarding/opening3.png',
                                height:
                                    MediaQuery.of(context).size.height * 0.30,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 50),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: _buildPageIndicator(),
                ),
              ),
              SizedBox(
                width: 175,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    _currentPage == 2
                        ? Navigator.pushNamed(context, '/welcome')
                        : _pageController.nextPage(
                            duration: Duration(milliseconds: 500),
                            curve: Curves.ease,
                          );
                  },
                  style: TextButton.styleFrom(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5)),
                    backgroundColor: Color.fromRGBO(86, 177, 191, 1),
                  ),
                  child: Text(
                    'NEXT',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
