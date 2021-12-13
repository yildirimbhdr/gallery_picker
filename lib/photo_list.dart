import 'package:flutter/material.dart';
import 'package:photo_gallery/photo_gallery.dart';
import 'package:transparent_image/transparent_image.dart';

class PhotoList extends StatefulWidget {
  final Album album;
  const PhotoList({Key? key, required this.album}) : super(key: key);

  @override
  _PhotoListState createState() => _PhotoListState();
}

class _PhotoListState extends State<PhotoList> {
  List<Medium> _selectedMediums = [];
  Future<List<Medium>> getListPhoto() async {
    MediaPage _mediaPage = await widget.album.listMedia();
    return _mediaPage.items;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appbar,
      body: FutureBuilder<List<Medium>>(
        future: getListPhoto(),
        builder: (context, snap) {
          if (snap.hasData) {
            return GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2),
              itemCount: snap.data?.length ?? 0,
              itemBuilder: (context, index) {
                Medium? _medium = snap.data?[index];
                if (_medium != null) {
                  return showPhoto(_medium);
                }
                return Container();
              },
            );
          }
          return Container();
        },
      ),
    );
  }

  showPhoto(Medium medium) {
    return InkWell(
      onTap: () {
        setState(() {
          if (_selectedMediums.any((element) => element.id == medium.id)) {
            _selectedMediums.removeWhere((element) => element.id == medium.id);
          } else {
            _selectedMediums.add(medium);
          }
        });
      },
      child: Container(
        decoration:
            BoxDecoration(border: Border.all(color: getBorderColor(medium))),
        child: FadeInImage(
          fit: BoxFit.cover,
          placeholder: MemoryImage(kTransparentImage),
          image: ThumbnailProvider(
              mediumId: medium.id,
              mediumType: MediumType.image,
              highQuality: true,
              width: 750,
              height: 750),
        ),
      ),
    );
  }

  Color getBorderColor(Medium medium) {
    return _selectedMediums.any((element) => element.id == medium.id)
        ? Colors.green
        : Colors.transparent;
  }

  AppBar get appbar => AppBar(
        title: Text(widget.album.name ?? ""),
        actions: [
          IconButton(
            icon: const Icon(Icons.done),
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context , _selectedMediums);
            },
          ),
        ],
      );
}
