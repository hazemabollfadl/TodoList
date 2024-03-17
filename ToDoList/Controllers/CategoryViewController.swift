import UIKit
import CoreData

class CategoryViewController: UITableViewController {

    
    var categoryArray=[Categories]()
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadItems()

    }
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
       
        var textResult = UITextField()
        
        let alert=UIAlertController(title: "Add New Category", message: "", preferredStyle: .alert )
        
        let action=UIAlertAction(title: "Add Category", style: .default) { action in
            
            //what happens when the user clicks add Category
            if textResult.text==""{
                let alert=UIAlertController(title: "Warning", message: "No Categories Were Added", preferredStyle: .alert)
                let action=UIAlertAction(title: "Ok", style: .default)
                alert.addAction(action)
                self.present(alert, animated: true)
            }else{
                //stores added item in the array of categoryArray
                
                let newCategory = Categories(context: self.context)
                newCategory.title = textResult.text!
                
                self.categoryArray.append(newCategory)
                
                self.saveItems()
                
            }
        }
        
        alert.addAction(action)
        alert.addTextField { alertTextField in
            alertTextField.placeholder="Create New Category"
            textResult=alertTextField
        }
        
        present(alert, animated: true)
    }
    
    //MARK: - UITableView Datasource Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoryArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell=UITableViewCell(style: .default, reuseIdentifier: "CategoryCell")
        
        let itemList=categoryArray[indexPath.row]
        
        cell.textLabel?.text=itemList.title
        
        return cell
    }
    
    //MARK: - UITableView Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        performSegue(withIdentifier: "goToItems", sender: self)
        
        saveItems()
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC=segue.destination as! TodoListVC
        
        if let indexPath=tableView.indexPathForSelectedRow{
            destinationVC.selectedCategory=categoryArray[indexPath.row]
        }
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            context.delete(categoryArray[indexPath.row])
            categoryArray.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            saveItems()
        }
    }
    
    
    
    //MARK: - Data Manipulation Methods
  
    func saveItems(){
        do{
            try context.save()
        }catch{
            print("Error saving the data\(error)")
        }
        tableView.reloadData()
    }
    
    func loadItems(with request: NSFetchRequest<Categories>=Categories.fetchRequest()){
        do {
            categoryArray = try context.fetch(request)
        }catch{
            print("Error fetching the data\(error)")
        }
        tableView.reloadData()
    }
}
