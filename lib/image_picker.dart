import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gallerypicker/photo_list.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_gallery/photo_gallery.dart';
import 'package:transparent_image/transparent_image.dart';

class ImagePickerPage extends StatefulWidget {
  const ImagePickerPage({Key? key}) : super(key: key);

  @override
  _ImagePickerPageState createState() => _ImagePickerPageState();
}

class _ImagePickerPageState extends State<ImagePickerPage> {
  _setPermission() async {
    await Permission.storage.request();
  }

  Future<List<Map<String, dynamic>>> _getAlbums() async {
    List<Map<String, dynamic>> _data = [];
    final List<Album> imageAlbums = await PhotoGallery.listAlbums(
      mediumType: MediumType.image,
    );
    for (Album element in imageAlbums) {
      MediaPage? _media = await element.listMedia(skip: 1, take: 1);
      if (_media.items.isNotEmpty) {
        Medium _medium = _media.items.first;
        File _file = await _medium.getFile();
        _data.add({"album": element});
      }
    }

    return _data;
  }

  @override
  void initState() {
    super.initState();
    _setPermission();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: images);
  }

  Widget get images => FutureBuilder<List<Map<String, dynamic>>>(
        future: _getAlbums(),
        builder: (context, snap) {
          if (snap.hasData) {
            List<Map<String, dynamic>> _albums = snap.data ?? [];
            return GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2),
              itemCount: _albums.length,
              itemBuilder: (context, index) {
                Album _album = _albums[index]["album"];
                return InkWell(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => PhotoList(album: _album)));
                  },
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      FadeInImage(
                        fit: BoxFit.cover,
                        placeholder: MemoryImage(kTransparentImage),
                        image: AlbumThumbnailProvider(
                          albumId: _album.id,
                          mediumType: MediumType.image,
                          highQuality: true,
                          width: 750,
                          height: 750
                        ),
                      ),
                      Container(
                        color: Colors.black.withOpacity(0.4),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(_album.name ?? "",
                                textAlign: TextAlign.center,
                                style: const TextStyle(color: Colors.white)),
                          ],
                        ),
                      )
                    ],
                  ),
                );
              },
            );
          }
          return Container();
        },
      );
}
