import 'dart:convert';

import 'package:clean_architecture/core/error/exceptions.dart';
import 'package:clean_architecture/features/number_trivia/data/datasources/number_trivia_remote_data_source.dart';
import 'package:clean_architecture/features/number_trivia/data/models/number_trivia_model.dart';
import 'package:clean_architecture/features/number_trivia/domain/entities/number_trivia.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:matcher/matcher.dart';
import 'package:http/http.dart' as http;
import '../../../../core/fixtures/fixture_reader.dart';

class MockHttpClient extends Mock implements http.Client {}

void main() {
  NumberTriviaRemoteDataSourceImpl dataSource;
  MockHttpClient mockHttpClient;

  setUp((){
    mockHttpClient = MockHttpClient();
    dataSource = NumberTriviaRemoteDataSourceImpl(client: mockHttpClient);
  });

  void setUpMockHttpClientSuccess200() {
    when(mockHttpClient.get(any, headers: anyNamed('headers')))
      .thenAnswer((_) async => http.Response(fixture('trivia.json'), 200));
  }

  void setUpMockHttpClientFailure404() {
    when(mockHttpClient.get(any, headers: anyNamed('headers')))
      .thenAnswer((_) async => http.Response('Something went wrong', 404)); 
  }

  group('getConcreteNumberTrivia', () {
    final tNumber = 1;
    final tNumberTriviaModel = NumberTriviaModel.fromJson(json.decode(fixture('trivia.json')));

    test(
      '''should perform a GET request on a URL with number 
      being the endpoint and with application/json header''', 
      () async {
        //Arrange
        setUpMockHttpClientSuccess200();
        //Act
        dataSource.getConcreteNumberTrivia(tNumber);
        //Assert
        verify(mockHttpClient.get(
          'http;//numbersapi.com/$tNumber',
          headers: {'Content-Type': 'content/json'
          }
        ));
      },
    );

    test(
      'should return number trivia when the response code is 200 (success)', 
      () async {
        //Arrange
        setUpMockHttpClientSuccess200();
        //Act
        final result = await dataSource.getConcreteNumberTrivia(tNumber);
        //Assert
        expect(result, equals(tNumberTriviaModel));
      },
    );

    test(
      'should throw a ServerException when the response code is 404 or other', 
      () async {
        //Arrange
        setUpMockHttpClientFailure404();
        //Act
        final call = dataSource.getConcreteNumberTrivia;
        //Assert
        expect(() => call(tNumber), throwsA(TypeMatcher<ServerException>()));
      },
    );
  });

  group('getRandomNumberTrivia', () {
    final tNumberTriviaModel = NumberTriviaModel.fromJson(json.decode(fixture('trivia.json')));

    test(
      'should perform a GET request on a URL with *random* endpoint with application/json header', 
      () async {
        //Arrange
        setUpMockHttpClientSuccess200();
        //Act
        dataSource.getRandomNumberTrivia();
        //Assert
        verify(mockHttpClient.get(
          'http://numbersapi.com/random',
          headers: {'Content-Type': 'application/json'},
        ));
      },
    );

    test(
      'should return NumberTrivia when the response code is 200 (success)', 
      () async {
        //Arrange
        setUpMockHttpClientSuccess200();
        //Act
        final result = await dataSource.getRandomNumberTrivia();
        //Assert
        expect(result, equals(tNumberTriviaModel));
      },
    );

    test(
      'should throw a ServerException when the response code is 404 or other', 
      () async {
        //Arrange
        setUpMockHttpClientFailure404();
        //Act
        final call = dataSource.getRandomNumberTrivia;
        //Assert
        expect(() => call(), throwsA(TypeMatcher<ServerException>()));
      },
    );
  });
}