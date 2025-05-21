import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:must_invest/core/extensions/string_to_icon.dart';
import 'package:must_invest/core/extensions/theme_extension.dart';
import 'package:must_invest/core/static/icons.dart';
import 'package:must_invest/core/theme/colors.dart';
import 'package:must_invest/core/utils/widgets/long_press_effect.dart';

class ImagePickerAvatar extends StatelessWidget {
  final bool? isLarge;
  final void Function(PlatformFile image) onPick;
  final double? height;
  final double? width;
  final PlatformFile? pickedImage;
  final String? initialImage;
  const ImagePickerAvatar({
    super.key,
    this.pickedImage,
    required this.onPick,
    this.isLarge = false,
    this.height,
    this.width,
    this.initialImage,
  });

  @override
  Widget build(BuildContext context) {
    bool isLight = context.theme.scaffoldBackgroundColor == AppColors.whiteFD;

    return SizedBox(
      height: height ?? (isLarge! ? 300 : 100),
      width: width ?? (isLarge! ? 300 : 100),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50),
                color:
                    pickedImage == null
                        ? (isLight ? AppColors.whiteF3 : AppColors.blueE2)
                        : null,
                image:
                    (initialImage != null &&
                            initialImage!.isNotEmpty &&
                            pickedImage == null)
                        ? DecorationImage(
                          fit: BoxFit.cover,
                          image: NetworkImage(initialImage!),
                        )
                        : pickedImage != null && pickedImage!.path != null
                        ? DecorationImage(
                          fit: BoxFit.cover,
                          image: FileImage(File(pickedImage!.path!)),
                        )
                        : null,
              ),
            ),
          ),
          if (pickedImage == null &&
              (initialImage == null || initialImage!.isEmpty))
            Positioned.fill(
              child: GestureDetector(
                onTap: () async {
                  // await Permission.manageExternalStorage.request();
                  final result = await FilePicker.platform.pickFiles(
                    type: FileType.image,
                    withData: true,
                    compressionQuality: 0,
                  );
                  if (result != null) {
                    onPick(result.files.first);
                  }
                },
                child: Material(
                  color: Colors.transparent,
                  child: SizedBox.expand(
                    // child: Image.asset(AppImages.logo),
                    // child: AppIcons.personIc.icon()
                    child: IconButton(
                      onPressed: () async {
                        final result = await FilePicker.platform.pickFiles(
                          type: FileType.image,
                          withData: true,
                          compressionQuality: 0,
                        );
                        if (result != null) {
                          onPick(result.files.first);
                        }
                      },
                      splashRadius: 50,
                      color: Theme.of(context).colorScheme.primary,
                      icon: Icon(
                        Icons.add_photo_alternate_outlined,
                        size: isLarge! ? 30 : 25.0,
                      ),
                    ),
                  ),
                ),
              ),
            )
          else
            PositionedDirectional(
              bottom: -10,
              start: -10,
              height: 40,
              width: 40,
              child: Container(
                height: 120,
                width: 120,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(60),
                  color: Colors.white,
                ),
                padding: const EdgeInsets.all(5),
                child: Material(
                  clipBehavior: Clip.hardEdge,
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(20),
                  child: Center(
                    child: IconButton(
                      onPressed: () async {
                        final result = await FilePicker.platform.pickFiles(
                          type: FileType.image,
                          withData: true,
                        );
                        if (result != null) {
                          onPick(result.files.first);
                        }
                      },
                      iconSize: 35,
                      splashRadius: 35,
                      color: isLight ? AppColors.white : AppColors.black,
                      icon: AppIcons.editIc.icon(),
                    ),
                  ),
                ),
              ).withPressEffect(
                onTap: () {
                  onPick(pickedImage!);
                },
              ),
            ),
        ],
      ),
    );
  }
}
