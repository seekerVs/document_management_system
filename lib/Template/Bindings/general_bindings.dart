import 'package:get/get.dart';
import '../OperatingSystem/Android/Page/Signature/Controller/signature_placement_controller.dart';
import '../OperatingSystem/Android/Page/Signature/Controller/signature_request_controller.dart';
import '../OperatingSystem/Android/Page/Tasks/Controller/tasks_controller.dart';
import '../OperatingSystem/Android/Page/Profile/Controller/user_controller.dart';
import '../OperatingSystem/Android/Page/Documents/Controller/upload_controller.dart';

class GeneralBindings extends Bindings {
  @override
  void dependencies() {
    // Current user session
    Get.put<UserController>(UserController(), permanent: true);

    // Signature request flow
    Get.lazyPut(() => SignatureRequestController(), fenix: true);
    Get.lazyPut(() => SignaturePlacementController(), fenix: true);
    Get.lazyPut(() => UploadController(), fenix: true);

    // Tasks
    Get.lazyPut(() => TasksController(), fenix: true);
  }
}
