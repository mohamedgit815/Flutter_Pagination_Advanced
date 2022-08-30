import 'package:animated_conditional_builder/animated_conditional_builder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test_app/fetch_data.dart';
import 'package:flutter_test_app/state.dart';

class FetchPage extends ConsumerStatefulWidget {
  const FetchPage({Key? key}) : super(key: key);

  @override
  ConsumerState<FetchPage> createState() => _FetchPageState();
}

class _FetchPageState extends ConsumerState<FetchPage> with _MobileFetchScreen {
  @override
  void initState() {
    super.initState();
    ref
        .read(_fetchDataProv)
        .fetchData(url: _url(), limit: _limit, page: _page++);

    _scrollController.addListener(() {
      ref.read(_mainState).countState(_scrollController.offset.toInt());

      if (_scrollController.position.maxScrollExtent ==
          _scrollController.offset) {
        ref
            .read(_fetchDataProv)
            .fetchData(url: _url(), limit: _limit, page: _page++);
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
  }

  @override
  void deactivate() {
    super.deactivate();
    _loadMore = false;
  }

  @override
  Widget build(BuildContext context) {
    if (_loadMore) {
      ref
          .read(_fetchDataProv)
          .fetchData(url: _url(), limit: _limit, page: _page++);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Pagination"),
        centerTitle: true,
        leading: BackButton(
          onPressed: () {
            _loadMore = false;
            Navigator.maybePop(context);
          },
        ),
      ),
      body: WillPopScope(
        onWillPop: () async {
          _loadMore = false;
          return true;
        },
        child: Consumer(builder: (context, prov, _) {
          return RefreshIndicator(
            onRefresh: () async {
              _loadMore = true;
              _page = 1;
              _limit = 10;
              setState(() {});

              return ref.read(_fetchDataProv).refreshData(_page);
            },
            child: Consumer(builder: (context, provider, _) {
              return AnimatedConditionalBuilder(
                  condition: provider.watch(_fetchDataProv).dataList.isNotEmpty,
                  builder: (BuildContext context) =>
                      Consumer(builder: (context, providerPhysics, _) {
                        return ListView.builder(
                            physics:
                                providerPhysics.watch(_mainState).count == 0
                                    ? const ScrollPhysics()
                                    : const BouncingScrollPhysics(),
                            itemCount:
                                provider.read(_fetchDataProv).dataList.length,
                            controller: _scrollController,
                            key: const PageStorageKey<String>(
                                "FetchPageKeyScreen"),
                            itemBuilder: (BuildContext context, int i) {
                              final FetchData prov =
                                  provider.read(_fetchDataProv);

                              final FetchModel model = FetchModel.fromJson(
                                  prov.dataList.elementAt(i));

                              int index = i;

                              if (prov.hasMore) {
                                index = i + 1;
                              } else {
                                index = i;
                              }

                              if (index < prov.dataList.length) {
                                return ListTile(
                                  leading: CircleAvatar(
                                      child: Text(model.id.toString())),
                                  key: ValueKey<int>(model.id),
                                  title: Text(model.title),
                                  subtitle: Text(model.body),
                                );
                              } else {
                                return Visibility(
                                    visible: !prov.hasMore ? false : true,
                                    child: const Center(
                                        child: CircularProgressIndicator()));
                              }
                            });
                      }),
                  fallback: (BuildContext context) =>
                      const Center(child: CircularProgressIndicator()));
            }),
          );
        }),
      ),
    );
  }
}

class _MobileFetchScreen {
  int _limit = 60;
  int _page = 1;
  bool _loadMore = false;

  String _url() {
    return 'https://jsonplaceholder.typicode.com/posts?_limit=$_limit&_page=$_page';
  }

  final _fetchDataProv =
      ChangeNotifierProvider<FetchData>((ref) => FetchData());

  final _mainState = ChangeNotifierProvider<MainState>((ref) => MainState());

  final ScrollController _scrollController = ScrollController();
}
