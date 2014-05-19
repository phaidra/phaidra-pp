use Mojolicious::Lite;
use Mango;
use Mango::BSON ':bson';

my $uri = 'mongodb://<user>:<pwd>@<host>/<db>';
helper mango => sub { state $mango = Mango->new($uri) };

get '/ls/user/:username/' => sub {
  my $self = shift;

  my $username = $self->param('username');

  my $collection = $self->mango->db->collection('lists');

  $collection->find({username => $username})->sort({updated => -1})->all(sub {
    my ($collection, $err, $res) = @_;

    return $self->render(json => { alerts => [{ type => 'danger', msg => $err }]}, status => 500) if $err;
    return $self->render(json => { lists => $res }, status => 200);

  });
};

get '/ls/:id/' => sub {
  my $self = shift;

  my $id = $self->param('id');

  my $collection = $self->mango->db->collection('lists');

  $collection->find({_id => Mango::BSON::ObjectID->new($id)})->sort({updated => -1})->all(sub {
    my ($collection, $err, $res) = @_;

    return $self->render(json => { alerts => [{ type => 'danger', msg => $err }]}, status => 500) if $err;
    return $self->render(json => { lists => $res }, status => 200);

  });
};

put '/ls/:username/' => sub {
  my $self = shift;

  my $username = $self->param('username');
  my $payload = $self->req->json;

  my $collection = $self->mango->db->collection('lists');

  $collection->insert({username => $username, created => bson_time, updated => bson_time, list => $payload } => sub {
    my ($collection, $err, $oid) = @_;

    return $self->render(json => { alerts => [{ type => 'danger', msg => $err }]}, status => 500) if $err;
    return $self->render(json => { id => $oid }, status => 200);
  });

};

post '/ls/:id/' => sub {
  my $self = shift;
  my $id = $self->param('id');
  my $payload = $self->req->json;

  my $collection = $self->mango->db->collection('lists');

  $collection->update({_id => Mango::BSON::ObjectID->new($id)},{ '$set' => {updated => bson_time, list => $payload} } => sub {
    my ($collection, $err, $oid) = @_;

    return $self->render(json => { alerts => [{ type => 'danger', msg => $err }]}, status => 500) if $err;
    return $self->render(json => { id => $oid }, status => 200);
  });

};

del '/ls/:id/' => sub {
  my $self = shift;
  my $id = $self->param('id');

  my $collection = $self->mango->db->collection('lists');

  $collection->remove({_id => Mango::BSON::ObjectID->new($id)} => sub {
    my ($collection, $err, $oid) = @_;

    return $self->render(json => { alerts => [{ type => 'danger', msg => $err }]}, status => 500) if $err;
    return $self->render(json => {}, status => 200);
  });

};

app->secrets(['secret']);
app->start;
                                                                                                                                                         89,11         Bot
