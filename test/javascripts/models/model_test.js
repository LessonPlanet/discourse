module("Discourse.Model");

test("mixes in Discourse.Presence", function() {
  ok(Discourse.Presence.detect(Discourse.Model.create()));
});

test("extractByKey: converts a list of hashes into a hash of instances of specified class, indexed by their ids", function() {
  var firstObject = {id: "id_1", foo: "foo_1"};
  var secondObject = {id: "id_2", foo: "foo_2"};

  var actual = Discourse.Model.extractByKey([firstObject, secondObject], Ember.Object);
  var expected = {
    id_1: Ember.Object.create(firstObject),
    id_2: Ember.Object.create(secondObject)
  };

  ok(_.isEqual(actual, expected));
});

test("extractByKey: returns an empty hash if there isn't anything to convert", function() {
  deepEqual(Discourse.Model.extractByKey(), {}, "when called without parameters");
  deepEqual(Discourse.Model.extractByKey([]), {}, "when called with an empty array");
});
