var feeds = [];
	
angular.module('feedModule', ['ngResource'])
	.factory('FeedLoader', function ($resource) {
		return $resource('http://ajax.googleapis.com/ajax/services/feed/load', {}, {
			fetch: { method: 'JSONP', params: {v: '1.0', callback: 'JSON_CALLBACK'} }
		});
	})
	.service('FeedList', function ($rootScope, FeedLoader) {
		this.get = function() {
			var feedSources = [
				{url: 'https://news.google.com/news/feeds?pz=1&cf=all&ned=us&hl=en&q=apple&output=rss'},
				{url: 'https://news.google.com/news/feeds?pz=1&cf=all&ned=us&hl=en&q=amazon&output=rss'},
				{url: 'https://news.google.com/news/feeds?pz=1&cf=all&ned=us&hl=en&q=chipotle&output=rss'},
                                {url: 'https://news.google.com/news/feeds?pz=1&cf=all&ned=us&hl=en&q=google&output=rss'},
                                {url: 'https://news.google.com/news/feeds?pz=1&cf=all&ned=us&hl=en&q=mastercard&output=rss'},
                                {url: 'https://news.google.com/news/feeds?pz=1&cf=all&ned=us&hl=en&q=priceline&output=rss'},
                                {url: 'https://news.google.com/news/feeds?pz=1&cf=all&ned=us&hl=en&q=twitter&output=rss'},
                                {url: 'https://news.google.com/news/feeds?pz=1&cf=all&ned=us&hl=en&q=visa&output=rss'},
			];
			if (feeds.length === 0) {
				for (var i=0; i<feedSources.length; i++) {
					FeedLoader.fetch({q: feedSources[i].url, num: 1}, {}, function (data) {
						var feed = data.responseData.feed;
						feeds.push(feed);
					});
				}
			}
			return feeds;
		};
	})
	.controller('FeedCtrl', function ($scope, FeedList) {
		$scope.feeds = FeedList.get();
		$scope.$on('FeedList', function (event, data) {
			$scope.feeds = data;
		});
	});
