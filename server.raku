use Cro::HTTP::Router;
use Cro::HTTP::Server;
use Cro::WebApp::Template;
use Cro::HTTP::Auth;

class Session does Cro::HTTP::Auth {
    has $.user-id is rw;

    method logged-in { $!user-id.defined }
}

subset LoggedIn of Session where *.logged-in;

my $application = route {
    template-location 'views/';

    # resolve static calls for css i.e. <link ...>
    get -> 'css', $file { static 'css', $file; }

    # GET /
    get -> { template 'index.html'; }

    get -> 'greet', $name { 
        template 'greet.html', { name => $name };
    }
}

my $PORT = 9999;
my $server = Cro::HTTP::Server.new: :port($PORT), :$application;

try {
    $server.start;
    say "Server started on http://localhost:$PORT :)";
} 
CATCH {
    say 'Server failed to start :(';
    default { .Str.say; };
}

# end the server on ctrl-c
react whenever signal(SIGINT) {
    $server.stop;
    exit;
}

