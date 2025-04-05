import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:socieaty/core/constants.dart';
import 'package:socieaty/core/network/api_client.dart';
import 'package:socieaty/core/network/api_result.dart';
import 'package:socieaty/core/utils/execute_request.dart';
import 'package:socieaty/features/authentication/repository/auth_local_repository.dart';
import 'package:socieaty/features/food-order/customer/viewstate/create_food_order_form_state.dart';
import 'package:socieaty/features/food-order/enum/food_order_status_enum.dart';
import 'package:socieaty/features/food-order/repository/request/get_orders_request_query.dart';
import 'package:socieaty/features/food-order/repository/request/paginate_orders_request_query.dart';
import 'package:socieaty/features/food-order/repository/response/create_order_transaction_response.dart';
import 'package:socieaty/features/food-order/repository/response/get_customer_food_order_transaction_response.dart';
import 'package:socieaty/features/food-order/repository/response/get_food_order_transaction_response.dart';
import 'package:socieaty/features/food-order/repository/response/get_orders_response.dart';
import 'package:socieaty/features/food-order/repository/response/get_restaurant_food_transaction_response.dart';
import 'package:socieaty/features/food-order/repository/response/paginate_orders_response.dart';
import 'package:socieaty/features/food-order/repository/response/track_order_transaction_response.dart';
import 'package:socieaty/features/food-order/repository/response/update_order_transaction_response.dart';

part 'food_order_repository.g.dart';

@riverpod
FoodOrderRepository foodOrderRepository(Ref ref) {
  final AuthLocalRepository authLocalRepository = ref.watch(authLocalRepositoryProvider);
  final token = authLocalRepository.getToken();
  return FoodOrderRepository(
    dio: ref.watch(apiClientProvider(url: AppConstants.socieatyBackendUrl, token: token)),
  );
}

class FoodOrderRepository {
  final Dio _dio;

  FoodOrderRepository({required Dio dio}) : _dio = dio;

  Future<ApiResult<CreateOrderTransactionResponse>> createOrderTransaction(
    CreateFoodOrderFormState data,
  ) async {
    return executeRequest<CreateOrderTransactionResponse>(
      requestFunction: () => _dio.post(
        'food-orders',
        data: data.toJson(),
      ),
      successParser: (data) => CreateOrderTransactionResponse.fromJson(data),
    );
  }

  Future<ApiResult<GetOrdersResponse>> getOrders(GetOrdersRequestQuery query) async {
    final queryData = {
      'customerId': query.customerId,
      'restaurantId': query.restaurantId,
      'createdAt': query.createdAt,
      'finishedAt': query.finishedAt,
      'status[]': List.generate(query.status.length, (index) => query.status[index].name),
      'sortBy': query.sortBy?.name,
      'sortOrder': query.sortOrder?.name,
    };
    return executeRequest<GetOrdersResponse>(
      requestFunction: () => _dio.get('food-orders', queryParameters: queryData),
      successParser: (data) => GetOrdersResponse.fromJson(data),
    );
  }

  Future<ApiResult<PaginateOrdersResponse>> paginateOrders(PaginateOrdersRequestQuery query) async {
    final queryData = {
      'customerId': query.customerId,
      'restaurantId': query.restaurantId,
      'createdAt': query.createdAt,
      'finishedAt': query.finishedAt,
      'status[]': List.generate(query.status.length, (index) => query.status[index].name),
      'sortBy': query.sortBy?.name,
      'sortOrder': query.sortOrder?.name,
      'paginationQuery': query.paginationQuery.toJson(),
    };
    return executeRequest<PaginateOrdersResponse>(
      requestFunction: () => _dio.get('food-orders/paginate', queryParameters: queryData),
      successParser: (data) => PaginateOrdersResponse.fromJson(data),
    );
  }

  Future<ApiResult<GetFoodOrderTransactionResponse>> getFoodOrderTransaction(String id) async {
    return executeRequest<GetFoodOrderTransactionResponse>(
      requestFunction: () => _dio.get('food-orders/$id'),
      successParser: (data) => GetFoodOrderTransactionResponse.fromJson(data),
    );
  }

  Future<ApiResult<TrackOrderTransactionResponse>> trackOrderTransaction(String id) async {
    return executeRequest<TrackOrderTransactionResponse>(
      requestFunction: () => _dio.get('food-orders/$id/track'),
      successParser: (data) => TrackOrderTransactionResponse.fromJson(data),
    );
  }

  Future<ApiResult<GetCustomerFoodOrderTransactionResponse>> getAllCustomerFoodOrderTransaction(
      List<FoodOrderStatus> status) async {
    return executeRequest<GetCustomerFoodOrderTransactionResponse>(
      requestFunction: () => _dio.get('food-orders/customer', queryParameters: {
        'status[]': List.generate(status.length, (index) => status[index].name),
      }),
      successParser: (data) => GetCustomerFoodOrderTransactionResponse.fromJson(data),
    );
  }

  Future<ApiResult<GetRestaurantFoodTransactionResponse>> getRestaurantFoodTransaction(
      List<FoodOrderStatus> status) async {
    return executeRequest<GetRestaurantFoodTransactionResponse>(
      requestFunction: () => _dio.get('food-orders/restaurant', queryParameters: {
        'status[]': List.generate(status.length, (index) => status[index].name),
      }),
      successParser: (data) => GetRestaurantFoodTransactionResponse.fromJson(data),
    );
  }

  Future<ApiResult<UpdateOrderTransactionResponse>> updateTransactionStatus(
      String id, FoodOrderStatus status) async {
    return executeRequest<UpdateOrderTransactionResponse>(
      requestFunction: () => _dio.put('food-orders/$id/', data: {'status': status.name}),
      successParser: (data) => UpdateOrderTransactionResponse.fromJson(data),
    );
  }
}
