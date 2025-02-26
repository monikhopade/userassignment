import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:assignment/data/models/user_model.dart';
part 'user_service.g.dart';

@RestApi(baseUrl: "https://reqres.in/api/")
abstract class UserService {
  factory UserService(Dio dio, {String baseUrl}) = _UserService;

  @GET("users")
  Future<UserResponse> getUsers(
    @Query("per_page") int perPage,
    @Query("page") int page,
  );
}