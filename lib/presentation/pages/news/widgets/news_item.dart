import 'package:auto_route/auto_route.dart';
import 'package:extended_image/extended_image.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:rtu_mirea_app/common/utils/strapi_utils.dart';
import 'package:rtu_mirea_app/domain/entities/news_item.dart';
import 'package:intl/intl.dart';
import 'package:rtu_mirea_app/presentation/core/routes/routes.gr.dart';
import 'package:rtu_mirea_app/presentation/pages/news/widgets/tag_badge.dart';
import 'package:rtu_mirea_app/presentation/theme.dart';
import 'package:shimmer/shimmer.dart';
import 'package:rtu_mirea_app/presentation/typography.dart';

class NewsItemWidget extends StatelessWidget {
  final NewsItem newsItem;
  final Function(String)? onClickNewsTag;

  const NewsItemWidget({Key? key, required this.newsItem, this.onClickNewsTag})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.router.push(NewsDetailsRoute(
          newsItem: newsItem,
        ));
        FirebaseAnalytics.instance.logEvent(name: 'view_news', parameters: {
          'news_title': newsItem.title,
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 24, left: 16, right: 16),
        decoration: BoxDecoration(
          color: AppTheme.colors.background02,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ExtendedImage.network(
                newsItem.images[0].formats != null
                    ? StrapiUtils.getMediumImageUrl(newsItem.images[0].formats!)
                    : newsItem.images[0].url,
                height: 175,
                width: MediaQuery.of(context).size.width,
                fit: BoxFit.cover,
                cache: false,
                borderRadius: BorderRadius.circular(16),
                shape: BoxShape.rectangle,
                loadStateChanged: (ExtendedImageState state) {
                  switch (state.extendedImageLoadState) {
                    case LoadState.loading:
                      return Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Shimmer.fromColors(
                          baseColor: AppTheme.colors.background03,
                          highlightColor:
                              AppTheme.colors.background03.withOpacity(0.5),
                          child: Container(
                            height: double.infinity,
                            width: double.infinity,
                            color: AppTheme.colors.background03,
                          ),
                        ),
                      );

                    case LoadState.completed:
                      return Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: ExtendedRawImage(
                          fit: BoxFit.cover,
                          height: 175,
                          width: double.infinity,
                          image: state.extendedImageInfo?.image,
                        ),
                      );

                    case LoadState.failed:
                      return GestureDetector(
                        child: const Stack(
                          fit: StackFit.expand,
                          children: <Widget>[
                            Positioned(
                              bottom: 0.0,
                              left: 0.0,
                              right: 0.0,
                              child: Text(
                                "Ошибка при загрузке изображения. Нажмите, чтобы перезагрузить",
                                textAlign: TextAlign.center,
                              ),
                            )
                          ],
                        ),
                        onTap: () {
                          state.reLoadImage();
                        },
                      );
                  }
                },
              ),
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text(newsItem.title,
                    textAlign: TextAlign.start, style: AppTextStyle.titleM),
              ),
              const SizedBox(height: 4),
              Text((DateFormat.yMMMd('ru_RU').format(newsItem.date).toString()),
                  textAlign: TextAlign.start,
                  style: AppTextStyle.captionL
                      .copyWith(color: AppTheme.colors.secondary)),
              newsItem.tags.isNotEmpty
                  ? const SizedBox(height: 16)
                  : Container(),
              _Tags(
                tags: newsItem.tags,
                onClick: onClickNewsTag,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Tags extends StatelessWidget {
  final List<String> tags;
  final Function(String)? onClick;

  const _Tags({
    Key? key,
    required this.tags,
    required this.onClick,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: tags
          .map(
            (element) => TagBadge(
              tag: element,
              onPressed: () {
                if (onClick != null) {
                  onClick!(element);
                }
              },
            ),
          )
          .toList(),
    );
  }
}
