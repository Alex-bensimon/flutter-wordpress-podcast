import 'package:graphql/client.dart';

final client = GraphQLClient(
  cache: GraphQLCache(),
  link: HttpLink('https://graphql.captainfact.io/'),
);

Future<QueryResult> getVideoData(String videoUrl) async {
  // Convert Vimeo URL to video ID
  final RegExp regExp = RegExp(
    r'(?:vimeo\.com\/|player\.vimeo\.com\/video\/)(\d+)',
  );
  final match = regExp.firstMatch(videoUrl);
  final videoId = match?.group(1) ?? '';

  final QueryOptions options = QueryOptions(
    document: gql('''
      query GetVideo(\$videoId: String!) {
        video(id: \$videoId) {
          id
          statements {
            id
            text
            time
            speaker {
              name
              title
            }
          }
        }
      }
    '''),
    variables: {
      'videoId': videoId,
    },
  );

  final result = await client.query(options);
  return result;
}
