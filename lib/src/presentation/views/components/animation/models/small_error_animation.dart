import 'package:monami/src/presentation/views/components/animation/lottie_animation_view.dart';
import 'package:monami/src/presentation/views/components/animation/models/lottie_animation.dart';

class SmallErrorAnimationView extends LottieAnimationView {
  const SmallErrorAnimationView({super.key})
      : super(
          animation: LottieAnimation.smallError,
        );
}
