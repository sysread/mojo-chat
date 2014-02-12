if (!window.console.log) {
    window.console.log = function() { };
}

function ChatService(opt) {
    this.opt = opt;

    if (!this.opt.name) {
        throw "opt.name not set";
    }

    if (!this.opt.url) {
        throw "opt.url not set";
    }

    this.ws = null;
    this.pending = [];
    this.is_connected = false;
    this.reconnect = setInterval(this.connect.bind(this), 1500);
}

ChatService.prototype.connect = function() {
    if (!this.is_connected) {
        console.log('Connecting to ' + this.opt.url);
        try {
            this.ws = new WebSocket(this.opt.url);
        } catch (e) {
            console.log(e);
            clearInterval(this.reconnect);
        }

        this.ws.onopen    = this.on_connect.bind(this);
        this.ws.onclose   = this.on_close.bind(this);
        this.ws.onmessage = this.recv.bind(this);
    }
};

ChatService.prototype.on_connect = function(e) {
    console.log('Connected to ' + this.opt.url);
    this.is_connected = true;
    while (this.pending.length > 0) {
        this.send(this.pending.shift());
    }
};

ChatService.prototype.on_close = function(e) {
    console.log('Disconnected from ' + this.opt.url);
    this.is_connected = false;
    this.ws = null;
};

ChatService.prototype.recv = function(e) {
    var response = JSON.parse(e.data);

    if (response.error) {
        alert(response.error);
        return;
    }

    if (response.topic) {
        this.opt.set_topic(response.topic);
    }

    if (response.users) {
        this.opt.set_users(response.users);
    }

    if (response.msgs) {
        this.opt.add_msgs(response.msgs);
    }
};

ChatService.prototype.send = function(msg) {
    console.log('Send: ' + msg);
    this.ws.send(msg);
};

ChatService.prototype.queue = function(msg) {
    msg = msg.trim();
    if (msg != '') {
        if (this.is_connected) {
            this.send(msg);
        } else {
            console.log('Queue: ' + msg);
            this.pending.push(msg);
            this.connect();
        }
    }
};

