String mapFirebaseErrorToArabic(String errorCode) {
  switch (errorCode) {
    case 'email-already-in-use':
      return 'هذا البريد الإلكتروني مستخدم بالفعل من قبل حساب آخر.';
    case 'invalid-email':
      return 'البريد الإلكتروني غير صحيح. الرجاء التحقق وإعادة المحاولة.';
    case 'user-not-found':
      return 'المستخدم غير موجود. الرجاء التحقق من البريد الإلكتروني وكلمة المرور.';
    case 'wrong-password':
      return 'كلمة المرور غير صحيحة. الرجاء التحقق وإعادة المحاولة.';
    case 'user-disabled':
      return 'تم تعطيل حساب المستخدم. الرجاء الاتصال بالدعم.';
    case 'too-many-requests':
      return 'تمت محاولات تسجيل الدخول الكثيرة لهذا الحساب. يرجى المحاولة مرة أخرى لاحقًا.';
    case 'admin-restricted-operation':
      return 'العملية مقيدة بصلاحيات المسؤول فقط.';
    case 'argument-error':
      return 'خطأ في الوسيطات الممررة إلى الدالة.';
    case 'app-not-authorized':
      return 'التطبيق غير مصرح به.';
    case 'app-not-installed':
      return 'التطبيق غير مثبت.';
    case 'captcha-check-failed':
      return 'فشلت عملية التحقق من CAPTCHA.';
    case 'code-expired':
      return 'انتهت صلاحية الرمز.';
    case 'email-already-in-use':
      return 'هذا البريد الإلكتروني مستخدم بالفعل من قبل حساب آخر.';
    case 'invalid-email':
      return 'البريد الإلكتروني غير صحيح. الرجاء التحقق وإعادة المحاولة.';
    case 'user-not-found':
      return 'المستخدم غير موجود. الرجاء التحقق من البريد الإلكتروني وكلمة المرور.';
    case 'wrong-password':
      return 'كلمة المرور غير صحيحة. الرجاء التحقق وإعادة المحاولة.';
    case 'user-disabled':
      return 'تم تعطيل حساب المستخدم. الرجاء الاتصال بالدعم.';
    case 'too-many-requests':
      return 'تمت محاولات تسجيل الدخول الكثيرة لهذا الحساب. يرجى المحاولة مرة أخرى لاحقًا.';
    case 'admin-restricted-operation':
      return 'العملية مقيدة بصلاحيات المسؤول فقط.';
    case 'argument-error':
      return 'خطأ في الوسيطات الممررة إلى الدالة.';
    case 'app-not-authorized':
      return 'التطبيق غير مصرح به.';
    case 'app-not-installed':
      return 'التطبيق غير مثبت.';
    case 'captcha-check-failed':
      return 'فشلت عملية التحقق من CAPTCHA.';
    case 'code-expired':
      return 'انتهت صلاحية الرمز.';
    case 'cordova-not-ready':
      return 'Cordova غير جاهز.';
    case 'cors-unsupported':
      return 'دعم CORS غير متوفر.';
    case 'credential-already-in-use':
      return 'الاعتماد المستخدم بالفعل.';
    case 'custom-token-mismatch':
      return 'رمز مخصص غير مطابق.';
    case 'requires-recent-login':
      return 'تتطلب العملية تسجيل الدخول الأخير.';
    case 'dependent-sdk-initialized-before-auth':
      return 'SDK المعتمدة تم تهيئتها قبل المصادقة.';
    case 'dynamic-link-not-activated':
      return 'الرابط الديناميكي غير مفعّل.';
    case 'email-change-needs-verification':
      return 'تغيير البريد الإلكتروني يحتاج إلى التحقق.';
    case 'email-already-in-use':
      return 'هذا البريد الإلكتروني مستخدم بالفعل من قبل حساب آخر.';
    case 'emulator-config-failed':
      return 'فشل تكوين المحاكي.';
    case 'expired-action-code':
      return 'انتهت صلاحية رمز الإجراء.';
    case 'cancelled-popup-request':
      return 'تم إلغاء طلب النافذة المنبثقة.';
    case 'internal-error':
      return 'خطأ داخلي.';
    case 'invalid-api-key':
      return 'مفتاح API غير صالح.';
    case 'invalid-app-credential':
      return 'اعتماد التطبيق غير صالح.';
    case 'invalid-app-id':
      return 'معرف التطبيق غير صالح.';
    case 'invalid-user-token':
      return 'رمز مميز للمستخدم غير صالح.';
    case 'invalid-auth-event':
      return 'حدث مصادقة غير صالح.';
    case 'invalid-cert-hash':
      return 'تجزئة شهادة التوثيق غير صالحة.';
    case 'invalid-verification-code':
      return 'رمز التحقق غير صالح.';
    case 'invalid-continue-uri':
      return 'URI متابعة غير صالح.';
    case 'invalid-cordova-configuration':
      return 'تكوين Cordova غير صالح.';
    case 'invalid-custom-token':
      return 'رمز مخصص غير صالح.';
    case 'invalid-dynamic-link-domain':
      return 'نطاق الرابط الديناميكي غير صالح.';
    case 'invalid-email':
      return 'البريد الإلكتروني غير صحيح. الرجاء التحقق وإعادة المحاولة.';
    case 'invalid-emulator-scheme':
      return 'مخطط المحاكي غير صالح.';
    case 'invalid-credential':
      return 'بيانات تسجيل الدخول غير صحيحة.';
    case 'invalid-message-payload':
      return 'حمولة الرسالة غير صالحة.';
    case 'invalid-multi-factor-session':
      return 'جلسة عامل متعدد غير صالحة.';
    case 'invalid-oauth-client-id':
      return 'معرف عميل OAuth غير صالح.';
    case 'invalid-oauth-provider':
      return 'موفر OAuth غير صالح.';
    case 'invalid-action-code':
      return 'رمز الإجراء غير صالح.';
    case 'unauthorized-domain':
      return 'نطاق غير مصرح به.';
    case 'wrong-password':
      return 'كلمة المرور غير صحيحة. الرجاء التحقق وإعادة المحاولة.';
    case 'invalid-persistence-type':
      return 'نوع الدائمية غير صالح.';
    case 'invalid-phone-number':
      return 'رقم هاتف غير صالح.';
    case 'invalid-provider-id':
      return 'معرف موفر غير صالح.';
    case 'invalid-recipient-email':
      return 'بريد إلكتروني للمستلم غير صالح.';
    case 'invalid-sender':
      return 'المرسل غير صالح.';
    case 'invalid-verification-id':
      return 'معرف التحقق غير صالح.';
    case 'invalid-tenant-id':
      return 'معرف المستأجر غير صالح.';
    case 'login-blocked':
      return 'تم حظر عملية تسجيل الدخول لهذا المستخدم.';
    case 'multi-factor-info-not-found':
      return 'معلومات عامل متعدد غير موجودة.';
    case 'multi-factor-auth-required':
      return 'تتطلب العملية المصادقة متعددة العوامل.';
    case 'missing-android-pkg-name':
      return 'اسم الحزمة لنظام Android مفقود.';
    case 'missing-app-credential':
      return 'اعتماد التطبيق مفقود.';
    case 'auth-domain-config-required':
      return 'يتطلب التكوين نطاق المصادقة.';
    case 'missing-verification-code':
      return 'رمز التحقق مفقود.';
    case 'missing-continue-uri':
      return 'متابعة URI مفقودة.';
    case 'missing-iframe-start':
      return 'بداية iframe مفقودة.';
    case 'missing-ios-bundle-id':
      return 'معرف الحزمة لنظام iOS مفقود.';
    case 'missing-or-invalid-nonce':
      return 'القيمة المستخدمة لـ nonce مفقودة أو غير صالحة.';
    case 'missing-multi-factor-info':
      return 'معلومات عامل متعدد مفقودة.';
    case 'missing-multi-factor-session':
      return 'جلسة عامل متعدد مفقودة.';
    case 'missing-phone-number':
      return 'رقم الهاتف مفقود.';
    case 'missing-password':
      return 'كلمة المرور مفقودة.';
    case 'missing-verification-id':
      return 'معرف التحقق مفقود.';
    case 'app-deleted':
      return 'تم حذف التطبيق.';
    case 'account-exists-with-different-credential':
      return 'الحساب موجود بالفعل بمعرّف مختلف.';
    case 'network-request-failed':
      return 'يوجد مشكلة في الاتصال بالانترنت';
    case 'null-user':
      return 'المستخدم غير موجود.';
    case 'no-auth-event':
      return 'لا يوجد حدث مصادقة.';
    case 'no-such-provider':
      return 'لا يوجد موفر.';
    case 'operation-not-allowed':
      return 'العملية غير مسموح بها.';
    case 'operation-not-supported-in-this-environment':
      return 'العملية غير مدعومة في هذا البيئة.';
    case 'popup-blocked':
      return 'تم حظر النافذة المنبثقة.';
    case 'popup-closed-by-user':
      return 'تم إغلاق النافذة المنبثقة بواسطة المستخدم.';
    case 'provider-already-linked':
      return 'تم ربط الموفر بالفعل بالحساب.';
    case 'quota-exceeded':
      return 'تم تجاوز الحد.';
    case 'redirect-cancelled-by-user':
      return 'تم إلغاء التوجيه بواسطة المستخدم.';
    case 'redirect-operation-pending':
      return 'العملية بانتظار التوجيه.';
    case 'rejected-credential':
      return 'تم رفض الاعتماد.';
    case 'second-factor-already-in-use':
      return 'العامل المزدوج مستخدم بالفعل.';
    case 'maximum-second-factor-count-exceeded':
      return 'تم تجاوز الحد الأقصى لعدد العوامل المزدوجة.';
    case 'tenant-id-mismatch':
      return 'عدم تطابق معرف المستأجر.';
    case 'timeout':
      return 'انتهت المهلة.';
    case 'user-token-expired':
      return 'انتهت صلاحية رمز المستخدم.';
    case 'too-many-requests':
      return 'تمت محاولات تسجيل الدخول الكثيرة لهذا الحساب. يرجى المحاولة مرة أخرى لاحقًا.';
    case 'unauthorized-continue-uri':
      return 'URI متابعة غير مصرح به.';
    case 'unsupported-first-factor':
      return 'العامل الأول غير مدعوم.';
    case 'unsupported-persistence-type':
      return 'نوع الدائمية غير مدعوم.';
    case 'unsupported-tenant-operation':
      return 'عملية المستأجر غير مدعومة.';
    case 'unverified-email':
      return 'البريد الإلكتروني غير موثق.';
    case 'user-cancelled':
      return 'ألغى المستخدم العملية.';
    case 'user-not-found':
      return 'المستخدم غير موجود. الرجاء التحقق من البريد الإلكتروني وكلمة المرور.';
    case 'user-disabled':
      return 'تم تعطيل حساب المستخدم. الرجاء الاتصال بالدعم.';
    case 'user-mismatch':
      return 'عدم تطابق المستخدم.';
    case 'user-signed-out':
      return 'خرج المستخدم.';
    case 'weak-password':
      return 'كلمة المرور ضعيفة.';
    case 'web-storage-unsupported':
      return 'تخزين الويب غير مدعوم.';
    case 'already-initialized':
      return 'تم التهيئة بالفعل.';
    case 'recaptcha-not-enabled':
      return 'لم يتم تمكين reCAPTCHA.';
    case 'missing-recaptcha-token':
      return 'رمز reCAPTCHA مفقود.';
    case 'invalid-recaptcha-token':
      return 'رمز reCAPTCHA غير صالح.';
    case 'invalid-recaptcha-action':
      return 'إجراء reCAPTCHA غير صالح.';
    case 'missing-client-type':
      return 'نوع العميل مفقود.';
    case 'missing-recaptcha-version':
      return 'إصدار reCAPTCHA مفقود.';
    case 'invalid-recaptcha-version':
      return 'إصدار reCAPTCHA غير صالح.';
    case 'invalid-req-type':
      return 'نوع الطلب غير صالح.';
    default:
      return 'حدث خطأ أثناء المعالجة. الرجاء المحاولة مرة أخرى لاحقًا.';
  }
}
