class ShakeUtility {

  bool canShake = false;

  /// Shake for half a second
  void shake({ required Function setState }) {

    setState(() => canShake = true);

    Future.delayed(const Duration(milliseconds: 500)).then((value) {
      
      setState(() => canShake = false );

    });

  }

}