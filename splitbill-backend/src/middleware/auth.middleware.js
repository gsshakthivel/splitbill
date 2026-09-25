import {verifyToken} from "../utils/jwt.js";

const authenticate = (req, res, next)=>{
    const authHeader = req.header("Authorization");
    
    const token = authHeader && authHeader.split(" ")[1];
    
    if(!token){
        return res.status(401).json({message: "Unauthorized"});
    }
    
    try {
        const decoded = verifyToken(token);
        req.user = decoded;
        next();
    } catch (error) {
        return res.status(401).json({message: "Invalid token"});
    }
};

export default authenticate;