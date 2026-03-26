import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../Commons/Widgets/placeholder_view.dart';
import '../../OperatingSystem/Android/Page/Dashboard/Controller/dashboard_controller.dart';
import '../../OperatingSystem/Android/Page/Dashboard/View/dashboard_view.dart';
import '../../OperatingSystem/Android/Page/Documents/Controller/documents_controller.dart';
import '../../OperatingSystem/Android/Page/Documents/Controller/upload_controller.dart';
import '../../OperatingSystem/Android/Page/Documents/View/document_viewer_view.dart';
import '../../OperatingSystem/Android/Page/Documents/View/documents_view.dart';
import '../../OperatingSystem/Android/Page/Documents/View/folder_contents_view.dart';
import '../../OperatingSystem/Android/Page/Password/Controller/forgot_password_controller.dart';
import '../../OperatingSystem/Android/Page/Password/View/forgot_password_view.dart';
import '../../OperatingSystem/Android/Page/Password/View/otp_verification_view.dart';
import '../../OperatingSystem/Android/Page/Password/View/reset_password_view.dart';
import '../../OperatingSystem/Android/Page/Profile/Controller/profile_controller.dart';
import '../../OperatingSystem/Android/Page/Profile/View/profile_view.dart';
import '../../OperatingSystem/Android/Page/SignIn/Controller/sign_in_controller.dart';
import '../../OperatingSystem/Android/Page/SignIn/Controller/sign_up_controller.dart';
import '../../OperatingSystem/Android/Page/SignIn/View/sign_in_view.dart';
import '../../OperatingSystem/Android/Page/SignIn/View/sign_up_view.dart';
import '../../OperatingSystem/Android/Page/Signature/View/add_recipient_view.dart';
import '../../OperatingSystem/Android/Page/Signature/View/recipients_list_view.dart';
import '../../OperatingSystem/Android/Page/Signature/View/select_document_view.dart';
import '../../OperatingSystem/Android/Page/Tasks/Controller/tasks_controller.dart';
import '../../OperatingSystem/Android/Page/Tasks/View/tasks_view.dart';
import '../../OperatingSystem/Android/Page/Signature/Controller/in_app_signing_controller.dart';
import '../../OperatingSystem/Android/Page/Signature/View/in_app_signing_view.dart';
import '../../OperatingSystem/Android/Page/Signature/View/request_review_view.dart';
import '../../OperatingSystem/Android/Page/Signature/View/signature_placement_view.dart';
import 'main_routes.dart';

class AppRoutes {
  AppRoutes._();

  static final List<GetPage> pages = [
    // ─── Auth ─────────────────────────────────────────────────────────────
    GetPage(
      name: MainRoutes.signIn,
      page: () => const SignInView(),
      binding: BindingsBuilder(
        () => Get.lazyPut(() => SignInController(), fenix: true),
      ),
    ),
    GetPage(
      name: MainRoutes.signUp,
      page: () => const SignUpView(),
      binding: BindingsBuilder(
        () => Get.lazyPut(() => SignUpController(), fenix: true),
      ),
    ),

    // ─── Forgot password flow ──────────────────────────────────────────────
    GetPage(
      name: MainRoutes.forgotPassword,
      page: () => const ForgotEmailView(),
      binding: BindingsBuilder(
        () => Get.lazyPut(() => ForgotPasswordController(), fenix: true),
      ),
    ),
    GetPage(name: MainRoutes.otpVerify, page: () => const OtpVerifyView()),
    GetPage(name: MainRoutes.newPassword, page: () => const NewPasswordView()),

    // ─── Dashboard ────────────────────────────────────────────────────────
    GetPage(
      name: MainRoutes.home,
      page: () => const DashboardView(),
      binding: BindingsBuilder(
        () => Get.lazyPut(() => DashboardController(), fenix: true),
      ),
    ),

    // ─── Documents ────────────────────────────────────────────────────────
    GetPage(
      name: MainRoutes.documents,
      page: () => const DocumentsView(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => DocumentsController(), fenix: true);
        Get.lazyPut(() => UploadController(), fenix: true);
      }),
    ),
    GetPage(
      name: MainRoutes.folderContents,
      page: () => const FolderContentsView(),
    ),
    GetPage(
      name: MainRoutes.documentViewer,
      page: () => const DocumentViewerView(),
    ),

    // ─── Tasks ────────────────────────────────────────────────────────────
    GetPage(
      name: MainRoutes.tasks,
      page: () => const TasksView(),
      binding: BindingsBuilder(
        () => Get.lazyPut(() => TasksController(), fenix: true),
      ),
    ),

    // ─── Signature request flow ───────────────────────────────────────────
    GetPage(
      name: MainRoutes.selectDocument,
      page: () => const SelectDocumentView(),
    ),
    GetPage(
      name: MainRoutes.addRecipient,
      page: () => const AddRecipientView(),
    ),
    GetPage(
      name: MainRoutes.recipientsList,
      page: () => const RecipientsListView(),
    ),
    GetPage(
      name: MainRoutes.signaturePlacement,
      page: () => const SignaturePlacementView(),
    ),
    GetPage(
      name: MainRoutes.requestReview,
      page: () => const RequestReviewView(),
    ),
    GetPage(
      name: MainRoutes.inAppSigning,
      page: () => const InAppSigningView(),
      binding: BindingsBuilder(
        () => Get.lazyPut(() => InAppSigningController(), fenix: true),
      ),
    ),

    // ─── Placeholders ─────────────────────────────────────────────────────
    GetPage(
      name: MainRoutes.folders,
      page: () => const PlaceholderView(
        title: 'Folders',
        icon: Icons.folder_open_outlined,
      ),
    ),
    GetPage(
      name: MainRoutes.signature,
      page: () => const PlaceholderView(
        title: 'Signature Requests',
        icon: Icons.draw_outlined,
      ),
    ),
    GetPage(
      name: MainRoutes.notifications,
      page: () => const PlaceholderView(
        title: 'Notifications',
        icon: Icons.notifications_outlined,
      ),
    ),
    GetPage(
      name: MainRoutes.activity,
      page: () => const PlaceholderView(
        title: 'Activity',
        icon: Icons.history_outlined,
      ),
    ),
    GetPage(
      name: MainRoutes.profile,
      page: () => const ProfileView(),
      binding: BindingsBuilder(
        () => Get.lazyPut(() => ProfileController(), fenix: true),
      ),
    ),
  ];
}
