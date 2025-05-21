// import 'package:must_invest/core/theme/colors.dart';
// import 'package:must_invest/core/utils/widgets/decoration/custom_box_decoration.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';

// import 'shimmer_container.dart';

// class PackageShimmerLoading extends StatelessWidget {
//   const PackageShimmerLoading({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       margin: const EdgeInsets.symmetric(vertical: 4),
//       clipBehavior: Clip.antiAlias,
//       decoration: customBorderShadowDecoration(
//         shadowColor: Colors.transparent,
//         borderColor: AppColors.greyEB,
//         borderWidth: 1.0,
//       ),
//       child: Row(
//         children: [
//           const ShimmerContainer(
//             height: 100,
//             width: 100,
//           ),
//           const SizedBox(width: 17),
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               ShimmerContainer(
//                 width: 120.w,
//                 height: 14.h,
//               ),
//               const SizedBox(height: 8),
//               ShimmerContainer(
//                 width: 80.w,
//                 height: 10.h,
//               ),
//               const SizedBox(height: 8),
//               ShimmerContainer(
//                 width: 150.w,
//                 height: 10.h,
//               ),
//               const SizedBox(height: 4),
//               ShimmerContainer(
//                 width: 100.w,
//                 height: 10.h,
//               ),
//               const SizedBox(height: 8),
//               ShimmerContainer(
//                 width: 80.w,
//                 height: 14.h,
//               ),
//             ],
//           ),
//           const Spacer(),
//           const ShimmerContainer(
//             width: 24,
//             height: 24,
//             isRounded: true,
//           ),
//         ],
//       ),
//     );
//   }
// }
