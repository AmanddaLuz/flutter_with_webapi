import 'package:http_interceptor/http_interceptor.dart';
import 'package:logger/logger.dart';

class LoggingInterceptor implements InterceptorContract {
  Logger logger = Logger();

  @override
  Future<RequestData> interceptRequest({required RequestData data}) async {
    logger.v("Requisição para: ${data.baseUrl}\n"
        "Cabeçalhos:${data.headers}\n"
        "Corpo: ${data.body}");
    return data;
  }

  @override
  Future<ResponseData> interceptResponse({required ResponseData data}) async {
    if (data.statusCode ~/ 100 == 2) {
      logger.i("Status da resposta: ${data.statusCode}\n"
          "Resposta de: ${data.url}\n"
          "Cabeçalhos:${data.headers}\n"
          "Corpo: ${data.body}");
    } else {
      logger.e("Status da resposta: ${data.statusCode}\n"
          "Resposta de: ${data.url}\n"
          "Cabeçalhos:${data.headers}\n"
          "Corpo: ${data.body}");
    }
    return data;
  }
}
