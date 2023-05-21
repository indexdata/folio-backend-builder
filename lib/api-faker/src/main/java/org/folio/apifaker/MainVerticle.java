package org.folio.apifaker;

import io.vertx.core.AbstractVerticle;
import io.vertx.core.Promise;
import io.vertx.ext.web.Router;

public class MainVerticle extends AbstractVerticle {

    @Override
    public void start(Promise<Void> promise)  {
        final int port = Integer.parseInt(System.getProperty("port", "8080"));
        Router router = Router.router(vertx);
        vertx.createHttpServer().requestHandler(router)
        .listen(port, result -> {
            if (result.succeeded()) {
                promise.complete();
            } else {
                promise.fail(result.cause());
            }
        });
    }
}
