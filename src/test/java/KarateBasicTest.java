import com.intuit.karate.junit5.Karate;

class KarateBasicTest {
    static {
        System.setProperty("karate.ssl", "true");
    }
    
    @Karate.Test
    Karate testBasic() {
        // Set the classpath where karate-config.js can be found
        System.setProperty("karate.config.dir", "classpath:.");
        return Karate.run("classpath:karate-test.feature");
    }
}
